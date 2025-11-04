# CI/CD Pipeline Setup Guide

This guide explains how to set up the automated Docker build and push pipeline to AWS ECR with manual approval.

## Overview

The pipeline automatically:
1. **Builds** the Docker image when backend code changes
2. **Requests approval** before pushing to ECR
3. **Pushes** the image to ECR after approval

## Prerequisites

1. GitHub repository with Actions enabled
2. AWS account with ECR repository created (via Terraform)
3. AWS IAM role for GitHub Actions (OIDC)

## Setup Steps

### 1. Create AWS IAM Role for GitHub Actions

Create an IAM role that GitHub Actions can assume using OIDC:

```bash
# Create trust policy (save as trust-policy.json)
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:YOUR_GITHUB_USERNAME/YOUR_REPO_NAME:*"
        }
      }
    }
  ]
}

# Create IAM role
aws iam create-role \
  --role-name GitHubActions-ECR-Role \
  --assume-role-policy-document file://trust-policy.json

# Attach ECR permissions
aws iam attach-role-policy \
  --role-name GitHubActions-ECR-Role \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess
```

### 2. Create OIDC Provider in AWS (if not exists)

```bash
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

### 3. Configure GitHub Secrets

Go to your GitHub repository → Settings → Secrets and variables → Actions → New repository secret:

- **AWS_ROLE_ARN**: `arn:aws:iam::YOUR_ACCOUNT_ID:role/GitHubActions-ECR-Role`

### 4. Configure GitHub Environment Protection

1. Go to Settings → Environments → New environment
2. Name it `production`
3. Add **Required reviewers** (select who can approve)
4. Optionally add deployment branches (e.g., `main` only)

### 5. Update Workflow Configuration

Edit `.github/workflows/docker-build-push.yml`:

```yaml
env:
  AWS_REGION: us-west-2  # Your AWS region
  ECR_REPOSITORY: myapp-backend  # Your ECR repository name (from terraform output)
```

### 6. Get Your ECR Repository Name

From your Terraform output:
```bash
cd terraform
terraform output ecr_repository_url
```

Update the `ECR_REPOSITORY` env variable in the workflow file (remove the AWS account and region prefix, just the repo name).

## How It Works

1. **Trigger**: Pipeline runs on:
   - Push to `main` or `develop` branches when backend files change
   - Manual trigger via GitHub Actions UI

2. **Build Job**: 
   - Builds Docker image
   - Tags with commit SHA and `latest`

3. **Push Job** (requires approval):
   - Waits for manual approval in GitHub
   - After approval, pushes image to ECR
   - Tags: `{commit-sha}` and `latest`

## Manual Approval Process

1. When pipeline runs, it will pause at the "Push to ECR" job
2. Go to GitHub Actions → Running workflow
3. Click "Review deployments"
4. Select "production" environment
5. Click "Approve and deploy"
6. Pipeline continues and pushes to ECR

## Testing

1. Make a change to `backend/Dockerfile` or any Python file
2. Commit and push to `main` branch
3. Check GitHub Actions tab
4. Approve when prompted
5. Verify image in AWS ECR console

## Troubleshooting

### Permission Denied
- Check IAM role has `AmazonEC2ContainerRegistryFullAccess` policy
- Verify OIDC provider exists
- Check GitHub secret `AWS_ROLE_ARN` is correct

### Image Not Found
- Verify ECR repository name matches in workflow
- Check AWS region is correct
- Ensure repository exists in AWS

### Approval Not Working
- Verify environment "production" is created in GitHub
- Check required reviewers are set
- Ensure you have permission to approve

## Alternative: Using GitHub Secrets (Simpler, less secure)

If OIDC setup is complex, you can use AWS access keys:

1. Create IAM user with ECR permissions
2. Add secrets to GitHub:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
3. Update workflow to use:
   ```yaml
   - uses: aws-actions/configure-aws-credentials@v4
     with:
       aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
       aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
       aws-region: ${{ env.AWS_REGION }}
   ```

**Note**: OIDC is recommended for production as it's more secure.

