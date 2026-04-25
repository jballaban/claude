# Panel

Convene a panel of domain experts on any question. Panel is a Claude Code plugin that runs multi-agent analysis across any topic — technical or not — and returns structured findings with a confidence rating.

Three tiers of depth. One consistent output format.

---

## Skills

| Skill | When to use |
|-------|-------------|
| `/ask` | Quick take. Small or scoped questions, sanity checks, fast triage before committing to deeper analysis. 1–3 agents. |
| `/panel` | Standard analysis. Feature work, strategic decisions, anything with non-obvious scope. 3–7 agents. |
| `/council` | Full deep dive. Greenfield systems, high-stakes decisions, migrations, security-critical work. 7–10 agents. |
| `/version` | Show the currently installed plugin version. |

---

## Installation

```bash
claude agent add jballaban/panel
```

---

## Usage

```
/ask Should I use a monorepo for this project?
```

```
/panel Add Stripe subscription billing to our Next.js app
```

```
/council Design a HIPAA-compliant healthcare data platform accessible to clinicians
```

Each skill runs the same pipeline at different depths:

1. Gathers project context from your working directory
2. Identifies the most relevant domains for your question
3. Synthesizes task-specific expert agents (not generic roles)
4. Runs all agents in parallel
5. Consolidates findings — blockers, risks, recommendations, tradeoffs
6. Validates the plan with a traffic-light rating round (🟢 PASS / 🟡 REVIEW / 🔴 RERUN)

---

## Escalation

The output of each tier tells you when to escalate:

- `/ask` → upgrade to `/panel` when the analysis surfaces more complexity than expected
- `/panel` → upgrade to `/council` when multiple red flags appear or the stakes are high
- `/council` → RERUN with additional context when critical concerns go unresolved

---

## What Panel is not

Panel produces analysis, not code. It won't implement what it recommends — use its output to inform your own work or hand it to another agent.
