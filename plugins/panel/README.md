# Panel

Convene a panel of domain experts on any question. Panel is a Claude Code plugin that runs multi-agent analysis across any topic — technical or not — and returns structured findings with a confidence rating.

Three tiers of depth. One consistent output format.

---

## Skills

| Skill | When to use |
|-------|-------------|
| `/ask` | Quick take. Small or scoped questions, sanity checks, fast triage before committing to deeper analysis. Up to 3 agents. |
| `/panel` | Standard analysis. Feature work, strategic decisions, anything with non-obvious scope. Up to 7 agents. |
| `/council` | Full deep dive. Greenfield systems, high-stakes decisions, migrations, security-critical work. Up to 10 agents. |
| `/plan` | Break a spec into a phased implementation plan with independently executable tasks per phase. |
| `/version` | Show the currently installed plugin version. |

---

## Installation

```bash
claude agent add jballaban/panel
```

**Requires Claude Code v2.1.32+ for the validation round.** The Step 6 deliberation uses [agent teams](https://code.claude.com/docs/en/agent-teams), which requires the experimental flag:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

If agent teams are not enabled, Step 6B falls back to parallel subagents (no direct teammate communication).

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
2. Identifies and tiers the most relevant domains (Critical / Important / Adjacent)
3. Maps domains to the agent catalog and synthesizes a task-specific agent roster
4. Runs all domain agents in parallel — each with a composed directive, not a generic role
5. Consolidates findings with dual weighting: item criticality × agent domain tier
6. Adversarial agent reviews the consolidated response before team deliberation
7. Domain agents deliberate as an agent team, fine-tuning the response to a 🟢 Green / 🟡 Yellow / 🔴 Red rating

---

## Escalation

The output of each tier tells you when to escalate:

- `/ask` → upgrade to `/panel` when the analysis surfaces more complexity than expected
- `/panel` → upgrade to `/council` when multiple red flags appear or the stakes are high
- `/council` → re-run with additional context when the result is 🔴 Red and critical concerns go unresolved
- Any tier → use `/plan` once you have a solid spec and want a phased implementation breakdown

---

## What Panel is not

Panel produces analysis, not code. It won't implement what it recommends — use its output to inform your own work or hand it to another agent.
