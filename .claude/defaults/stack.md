# Default Stack

> **These are this team's opinionated technology defaults. The Architect and DevOps follow these without debate unless the project's `conventions.md` explicitly overrides a specific item with a documented reason.**
>
> **If you are adopting this framework for a different team or stack, replace the contents of this file. The principles in `.claude/framework/architecture-standards.md` still apply.**

---

## Hosting & Infrastructure

- **Cloud platform:** AWS
- **Compute:** Serverless-first — Lambda for functions, Fargate for containers when a long-running process is genuinely required
- **Scaling:** Auto-scaling by default. No fixed-capacity servers unless there is an explicit, documented reason
- **IaC:** AWS CDK in TypeScript for all infrastructure definitions

## CI/CD

- **Merge to `main`** → automatically deploys to production
- **Merge to `next`** → automatically deploys to staging
- **Feature branches** → ephemeral AWS environment spun up by DevOps when backend infrastructure is required; destroyed on branch merge or deletion

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
- **Runtime:** Node.js (latest LTS)
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
