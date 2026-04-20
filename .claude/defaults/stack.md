# Default Stack

> **These are this team's opinionated technology defaults. The Architect and DevOps follow these without debate unless the project's `conventions.md` explicitly overrides a specific item with a documented reason.**
>
> **If you are adopting this framework for a different team or stack, replace the contents of this file. The principles in `.claude/framework/architecture-standards.md` still apply.**

---

## Developer Environment

- **OS:** Windows with WSL2 (Ubuntu) required for all development
- **File storage:** Projects stored on Windows filesystem (`C:\projects\`) — accessible normally in Explorer, TortoiseGit, and all Windows tools; WSL2 accesses via `/mnt/c/projects/`
- **Terminal:** Windows Terminal running WSL2 bash
- **Editor:** Cursor with WSL extension (connects transparently to WSL2); all tooling runs inside WSL2
- **Line endings:** `.gitattributes` enforcing LF for all text files — prevents CRLF contamination from Windows tools
- **All manual commands** in documentation are written for WSL2 bash — not PowerShell or cmd

## Hosting & Infrastructure

- **Cloud platform:** AWS
- **Region:** `us-east-1` (primary region for all projects)
- **Account strategy:** Separate AWS accounts per environment — dev (ephemeral feature environments), staging (`next` branch), production (`main` branch)
- **Compute:** Serverless-first — Lambda for functions, Fargate for containers when a long-running process is genuinely required
- **Scaling:** Auto-scaling by default. No fixed-capacity servers unless there is an explicit, documented reason
- **IaC:** AWS CDK in TypeScript for all infrastructure definitions
- **DNS:** Route 53 for all domain management
- **CDN:** CloudFront for all static asset delivery

## CI/CD

- **Platform:** GitHub Actions
- **Authentication:** OIDC — no long-lived AWS credentials stored anywhere; each environment has an IAM role with a trust policy scoped to this repository; role ARNs stored in GitHub Secrets (`AWS_ROLE_DEV`, `AWS_ROLE_STAGING`, `AWS_ROLE_PROD`)
- **On every PR:** TypeScript type check, ESLint, unit tests — PR cannot merge if any fail
- **Merge to `main`** → automatically deploys to production AWS account
- **Merge to `next`** → automatically deploys to staging AWS account
- **Feature branch push** → ephemeral CDK stack deployed to dev AWS account; stack name includes branch name; destroyed automatically on branch merge or deletion
- **Resource naming:** `{project}-{env}-{resource}` e.g. `myapp-prod-api`, `myapp-staging-table`

## Storage

- **Relational data:** Aurora Serverless v2 (PostgreSQL-compatible)
- **Key-value / high-throughput:** DynamoDB
- **File storage:** S3
- **Async queuing:** SQS — default pattern for all background processing and decoupled async work; do not do async work synchronously in API calls
- **Transactional email:** SES — welcome emails, password resets, notifications; do not add external email providers (SendGrid, Mailgun) when SES suffices
- **Caching:** ElastiCache (Redis) when a measured performance problem justifies it — always-on cost even at zero traffic; do not add speculatively
- **Search:** OpenSearch when full-text search is required — evaluate cost before adding

## Application

- **Language:** TypeScript for all new code — frontend and backend
- **TypeScript mode:** `strict` always enabled — no exceptions
- **Runtime:** Node.js (latest LTS)
- **Package manager:** pnpm
- **Project structure:** Monorepo using pnpm workspaces — packages for frontend, backend, infrastructure (CDK), and shared types
- **Code quality:** ESLint and Prettier configured on project init; enforced in CI on every PR
- **API style:** REST for external APIs; direct Lambda invocation for internal service-to-service

## Frontend

- **Framework:** Next.js (App Router)
- **Styling:** Tailwind CSS
- **Deployment:** Vercel (preferred for simplicity) or AWS Amplify

## Authentication

- **Default:** AWS Cognito
- **Social / SSO:** Via Cognito identity federation

## Observability

- **Logging:** CloudWatch Logs — structured JSON only
- **Tracing:** AWS X-Ray
- **Alerting:** CloudWatch Alarms → SNS

## Security Defaults

- All secrets in AWS Secrets Manager — never in environment variables, code, or committed files
- IAM least-privilege for all Lambda execution roles — no wildcard permissions
- VPC for all data stores

---

## Overrides

Document any deviation in `conventions.md`:

```
## Stack overrides
- Using MongoDB instead of Aurora Serverless: existing data model from acquired system, migration planned for v4
```

The Architect and DevOps must both agree on any override. Overrides that introduce significant cost, operational complexity, or security risk are raised to the product owner.
