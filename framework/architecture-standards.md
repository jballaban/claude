# Architecture Principles

> **These principles apply universally to all projects using this framework. They are not stack choices — they are engineering standards the Architect and Developer follow regardless of the technology in use. Override in `conventions.md` only with strong justification.**

---

**Code-first:** Everything is defined in code. No manual changes through cloud consoles, admin UIs, or any other interface. If it is not in code, it does not exist. Infrastructure is IaC. Configuration is committed. Runbooks are walkthroughs, not click-throughs.

**When no IaC API exists:** Produce a clear numbered walkthrough document. Store it in the project's `docs/` folder. This is the exception, not the pattern.

**Simple over complex:** Readable, obvious code and infrastructure. No premature abstraction. No clever one-liners. No over-engineered patterns. A future agent or developer should understand any piece of code or configuration immediately.

**Minimal dependencies:** If the language runtime or standard library handles it natively, do not add a package. Every dependency is a maintenance liability and a potential vulnerability. Justify any addition.

**Latest stable versions:** Always use the latest stable release of every dependency, runtime, and service feature. No pinned-old versions. No RC or beta releases. Dependencies are actively kept current.

**Automated deployments:** Merging to a branch deploys to its environment automatically. No manual deployment steps. If a deployment requires a human action, it is a process failure — automate it or document why it cannot be automated.

**Ephemeral environments:** Feature branches that require infrastructure get a scoped environment spun up and torn down automatically. Nothing persists unnecessarily.

**Security baseline:** All APIs require authentication unless explicitly marked public in the spec. Secrets are never in environment variables, code, or committed files — use a secrets manager. Apply least-privilege to all service execution roles. OWASP Top 10 compliance is the minimum bar for all code.
