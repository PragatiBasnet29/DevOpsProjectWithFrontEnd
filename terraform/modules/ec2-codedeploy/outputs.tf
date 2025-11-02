output "ec2_instance_public_ip" {
  value = aws_autoscaling_group.asg.instances[0].public_ip
}
