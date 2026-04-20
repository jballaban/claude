# Environments

## Production
- **Branch:** `main`
- **Deploy trigger:** Merge to `main` → CI automatically deploys
- **URL:** <!-- https://yourproduct.com -->
- **AWS account:** <!-- account ID or alias -->
- **AWS region:** <!-- e.g. us-east-1 -->

## Staging
- **Branch:** `next`
- **Deploy trigger:** Merge to `next` → CI automatically deploys
- **URL:** <!-- https://staging.yourproduct.com -->
- **AWS account:** <!-- account ID or alias -->
- **AWS region:** <!-- e.g. us-east-1 -->

## Ephemeral feature environments
- **Trigger:** Created by DevOps when a feature branch requires AWS backend infrastructure
- **Naming:** <!-- e.g. feature-{branch-name} -->
- **Teardown:** Destroyed automatically when branch is merged or deleted
- **Local dev:** Frontend served locally where possible; ephemeral AWS environment used only when backend is required

## Local development
<!-- How to run the project locally. Step-by-step. -->

## Secrets
- All secrets stored in AWS Secrets Manager
- Secret values are set by a human operator — never by an agent
- <!-- Document the secret naming convention, e.g. /{env}/{service}/{key} -->

## CI/CD
- <!-- CI/CD platform: e.g. GitHub Actions -->
- <!-- Link to workflow files -->
