resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ec2_attach_codedeploy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile-${var.env}"
  role = aws_iam_role.ec2_role.name
}

resource "aws_launch_template" "ec2_lt" {
  name_prefix   = "${var.project_name}-${var.env}-lt"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  user_data = base64encode(templatefile("${path.module}/userdata.sh.tpl", {
    ecr_repo_url      = var.ecr_repository_url
    container_name    = "${var.project_name}-backend"
  }))

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_security_group" "ec2_sg" {
  name   = "${var.project_name}-ec2-sg-${var.env}"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["your-ip-address/32"] # Replace with your office/home IP for SSH
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_autoscaling_group" "asg" {
  desired_capacity     = 1
  max_size             = 1
  min_size             = 1
  launch_template {
    id      = aws_launch_template.ec2_lt.id
    version = "$Latest"
  }
  vpc_zone_identifier = var.public_subnet_ids
  tags = [{
    key                 = "Name"
    value               = "${var.project_name}-asg-${var.env}"
    propagate_at_launch = true
  }]
}

resource "aws_codedeploy_app" "codedeploy_app" {
  name = "${var.project_name}-codedeploy-${var.env}"
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "deployment_group" {
  app_name              = aws_codedeploy_app.codedeploy_app.name
  deployment_group_name = "${var.project_name}-deployment-group-${var.env}"
  service_role_arn      = aws_iam_role.codedeploy_role.arn
  auto_scaling_groups   = [aws_autoscaling_group.asg.name]
}

resource "aws_iam_role" "codedeploy_role" {
  name = "${var.project_name}-codedeploy-role-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.codedeploy_assume_role.json
}

data "aws_iam_policy_document" "codedeploy_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "codedeploy_attach_managed" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

output "ec2_instance_public_ip" {
  value = aws_autoscaling_group.asg.instances[0].public_ip
}
