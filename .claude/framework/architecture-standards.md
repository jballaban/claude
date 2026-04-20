# Architecture Standards

> **These are the default technical decisions for all projects using this framework. The Architect and DevOps follow these defaults without debate. Override specific items in the project's `conventions.md` when the project context requires it — document the reason. Do not deviate without an explicit override.**

---

## Core Principles

**Code-first:** Everything is defined in code. No manual changes through AWS console, GitHub UI, or any other interface. If it is not in code, it does not exist. Infrastructure is CDK. Configuration is committed. Runbooks are walkthroughs, not console click-throughs.

**When no CDK API exists:** Produce a clear numbered walkthrough document. Store it in the project's `docs/` folder. This is the exception, not the pattern — prefer CDK wherever an API exists.

**Simple over complex:** Readable, obvious code and infrastructure. No premature abstraction. No clever one-liners. No over-engineered patterns. A future agent or developer should understand any piece of code or configuration immediately.

**Minimal dependencies:** If the language runtime or AWS SDK handles it natively, do not add a package. Every dependency is a maintenance liability and a potential vulnerability. Justify any addition.

**Latest stable versions:** Always use the latest stable release of every dependency, runtime, and AWS service feature. No pinned-old versions. No RC or beta releases. Dependencies are actively kept current — not left to drift.

---

## Hosting & Infrastructure

- **Platform:** AWS
- **Compute:** Serverless-first — Lambda for functions, Fargate for containers when a long-running process is genuinely required
- **Scaling:** Auto-scaling by default. No fixed-capacity servers unless there is an explicit, documented reason
- **IaC:** AWS CDK in TypeScript for all infrastructure definitions

## CI/CD

- **Merge to `main`** → automatically deploys to production
- **Merge to `next`** → automatically deploys to staging
- **Feature branches** → ephemeral AWS environment spun up by DevOps when backend infrastructure is required; destroyed on branch merge or deletion
- No manual deployment steps. If a deployment requires a human action, it is a process failure — automate it or document why it cannot be automated

## Storage

- **Relational data:** Aurora Serverless v2 (PostgreSQL-compatible)
- **Key-value / high-throughput:** DynamoDB
- **Caching:** ElastiCache (Redis) when a caching layer is needed
- **File storage:** S3
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

- All APIs require authentication unless explicitly marked public in the spec
- All secrets in AWS Secrets Manager — never in environment variables, code, or committed files
- IAM least-privilege for all Lambda execution roles — no wildcard permissions
- VPC for all data stores
- OWASP Top 10 compliance is the baseline for all code

---

## Overrides

Document any deviation from the above in `conventions.md`:

```
## Architecture overrides
- Using MongoDB instead of Aurora Serverless: existing data model from acquired system, migration planned for v4
```

The Architect and DevOps must both agree on any override. Overrides that introduce significant cost, operational complexity, or security risk are raised to the product owner.
