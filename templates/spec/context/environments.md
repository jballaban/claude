# Environments

## Production
- **Branch:** `main`
- **Deploy trigger:** Merge to `main` → GitHub Actions deploys automatically
- **URL:** <!-- https://yourproduct.com -->
- **AWS account ID:** <!-- 123456789012 -->
- **AWS region:** `us-east-1`

## Staging
- **Branch:** `next`
- **Deploy trigger:** Merge to `next` → GitHub Actions deploys automatically
- **URL:** <!-- https://staging.yourproduct.com -->
- **AWS account ID:** <!-- 123456789012 -->
- **AWS region:** `us-east-1`

## Dev (ephemeral)
- **AWS account ID:** <!-- 123456789012 -->
- **AWS region:** `us-east-1`
- **Stack naming:** `{project}-dev-{branch-name}`
- **Trigger:** GitHub Actions deploys on feature branch push when backend infrastructure is required
- **Teardown:** Automatic on branch merge or deletion

## Local development

**Requirements:** Windows with WSL2 (Ubuntu). All commands below run in WSL2 bash.

**First-time setup:**
1. Install WSL2: `wsl --install` in PowerShell (restart required)
2. Install Node.js in WSL2: `curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - && sudo apt-get install -y nodejs`
3. Install pnpm: `npm install -g pnpm`
4. Clone the repo to Windows filesystem: `cd /mnt/c/projects && git clone {repo-url}`
5. Install dependencies: `pnpm install`
6. Copy `.env.example` to `.env.local` and fill in values

**Running locally:**
<!-- Document how to start the dev server(s) -->

## Secrets

- All secrets stored in AWS Secrets Manager
- Naming convention: `/{env}/{service}/{key}` e.g. `/prod/stripe/secret-key`
- Secret values are set by a human operator — never by an agent

## GitHub Actions setup (one-time per project)

OIDC authentication — no long-lived AWS credentials stored anywhere.

1. In each AWS account, create an OIDC identity provider for GitHub Actions:
   - Provider URL: `https://token.actions.githubusercontent.com`
   - Audience: `sts.amazonaws.com`
2. Create a deployment IAM role in each account with a trust policy scoped to this repository
3. Add role ARNs to GitHub repository secrets:
   - `AWS_ROLE_DEV` — dev account role ARN
   - `AWS_ROLE_STAGING` — staging account role ARN
   - `AWS_ROLE_PROD` — production account role ARN

<!-- Link to CDK stack that provisions the OIDC provider and IAM roles -->
