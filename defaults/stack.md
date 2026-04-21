# Default Stack

> **These are this team's opinionated technology defaults. The Architect and DevOps follow these without debate unless the project's `conventions.md` explicitly overrides a specific item with a documented reason.**
>
> **If you are adopting this framework for a different team or stack, replace the contents of this file. The principles in `framework/architecture-standards.md` still apply.**

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

## Frontend (Web)

- **Framework:** Next.js (App Router)
- **Styling:** Tailwind CSS
- **Components:** shadcn/ui — components are copied into the repo and owned by the project, no dependency lock-in
- **Forms:** React Hook Form + Zod for validation
- **Client state / data fetching:** TanStack Query for complex client-side server state; Next.js server components and actions for everything else
- **Testing:** Vitest for unit tests; Playwright for end-to-end
- **Deployment:** Vercel (preferred for simplicity) or AWS Amplify

## Frontend (Mobile)

- **Framework:** Expo (React Native) — lives as a workspace package in the monorepo alongside the web app
- **Navigation:** Expo Router (file-based, consistent with Next.js App Router mental model)
- **Builds:** EAS Build (Expo Application Services) — cloud builds for both iOS and Android; no Mac required for iOS; Windows developers can ship to both platforms
- **Deployment:** EAS Submit for app store submissions

## Authentication

- **Provider:** AWS Cognito
- **Default UX:** Passwordless-first — magic link or OTP via SES; users should not be forced to create passwords unless explicitly required
- **Social login:** Google and Apple Sign-In via Cognito identity federation
- **Apple Sign-In:** Required on iOS if any other social login is offered — non-negotiable App Store rule
- **Mobile:** Cognito via Amplify Auth SDK for Expo
- **Password-based auth:** Only when the spec explicitly requires it

## Observability

- **Logging:** CloudWatch Logs — structured JSON only
- **Tracing:** AWS X-Ray
- **Alerting:** CloudWatch Alarms → SNS
- **Error tracking:** Sentry — exception grouping, stack traces, user context; SDK installed on web (Next.js), mobile (Expo), and backend (Lambda)
- **Analytics & session replay:** PostHog — user analytics, session replay, and feature flags in one tool; works across web and mobile (Expo SDK available); self-hostable if required

## Security Defaults

- All secrets in AWS Secrets Manager — never in environment variables, code, or committed files
- IAM least-privilege for all Lambda execution roles — no wildcard permissions
- VPC for all data stores
- WAF enabled on all public-facing API Gateway and CloudFront distributions — AWS Managed Rules as baseline
- API Gateway throttling enabled by default — limits defined per project in CDK; never left unlimited

## AI Integration

- **SDK:** Anthropic TypeScript SDK (`@anthropic-ai/sdk`)
- **Models:** claude-opus-4-7 for complex reasoning (Architect, Analyst, Security agents); claude-sonnet-4-6 for standard tasks; claude-haiku-4-5-20251001 for lightweight or high-volume operations
- **Prompt caching:** Enabled by default for all long system prompts — reduces cost and latency significantly
- **Streaming:** Required for all user-facing Claude responses — never block waiting for a complete response
- **Model references:** Never hardcode model name strings in application code — define as named constants in a single config file so upgrades are a one-line change

## Payments

- **Provider:** Stripe for all payment processing, subscriptions, and invoicing
- **Webhooks:** All Stripe webhook events verified server-side using Stripe signature before processing — never trust unverified webhook payloads
- **Card data:** Never stored — Stripe handles all PCI compliance; use Stripe Elements or Stripe Checkout on the frontend
- **Subscriptions:** Stripe Customer Portal for self-serve subscription management

## Notifications

- **Mobile push:** Expo Notifications SDK — EAS manages APNs (iOS) and FCM (Android) credentials; no direct APNs/FCM integration required
- **Backend delivery:** AWS SNS as the fan-out layer — Lambda publishes to SNS, SNS delivers to push, email (SES), or SMS targets
- **In-app notifications:** Stored in DynamoDB, surfaced via API; real-time delivery via API Gateway WebSocket or polling

## Testing

- **Web unit tests:** Vitest — for web, shared packages, and Lambda functions
- **Web E2E tests:** Playwright — for web critical paths
- **Mobile unit tests:** Jest with Expo test utilities
- **Mobile E2E tests:** Maestro — YAML-based UI flows tested on device or simulator; works with Expo Go and native builds; runs in CI via EAS
- **Backend unit tests:** Vitest with `@aws-sdk/client-mock` — mock AWS SDK calls to test Lambda logic in isolation without infrastructure
- **Backend integration tests:** Run against the ephemeral feature environment in CI after deploy — tests hit real DynamoDB, SQS, API Gateway; no LocalStack needed
- **File location:** Test files co-located with source (`foo.test.ts` next to `foo.ts`)
- **Coverage:** No minimum percentage enforced — it is a gameable metric; all business logic and edge cases must have unit tests; critical user paths must have E2E coverage
- **CI gate:** All tests must pass before a PR can merge

## Backups & Recovery

- **Aurora Serverless v2:** Automated backups with 7-day retention (AWS default of 1 day is insufficient); point-in-time recovery (PITR) enabled; manual snapshot taken before every major migration or destructive schema change
- **DynamoDB:** PITR enabled on all production tables — 35-day continuous backup window, zero performance impact
- **S3:** Versioning enabled on all production buckets — protects against accidental deletion and overwrites
- **Cross-region replication:** Not enabled by default — adds cost and complexity; document as an option in `conventions.md` for projects with high-availability requirements
- **Restoration testing:** DevOps must periodically verify that backups can actually be restored — untested backups are unreliable; schedule restore tests and document results

## Conventions

- **Branch naming:** `feature/{issue-number}-{short-description}`, `fix/{issue-number}-{short-description}`, `chore/{short-description}`
- **Commit format:** Imperative, present tense — "Add user auth" not "Added user auth"; one subject line; body optional for non-obvious decisions
- **PR format:** Title matches the issue; body includes what changed, why, and how to test; linked to GitHub issue
- **PR merges:** Squash merge to keep `main` and `next` history clean
- **Code review:** PRs require at least one approval before merge; all CI checks must pass

---

## Overrides

Document any deviation in `conventions.md`:

```
## Stack overrides
- Using MongoDB instead of Aurora Serverless: existing data model from acquired system, migration planned for v4
```

The Architect and DevOps must both agree on any override. Overrides that introduce significant cost, operational complexity, or security risk are raised to the product owner.
