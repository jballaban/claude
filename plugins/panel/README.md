# The Council of Elrond

*"Strangers from distant lands, friends of old. You have been summoned here to answer the threat of Mordor."*

A Claude Code plugin that convenes a panel of named experts on any question — then lets you shape who is at the table before they deliberate.

---

## Skills

| Skill | Description |
|-------|-------------|
| `/elrond` | Speak to Elrond directly. He will hear your need and convene the right counsel. |
| `/council` | Convene the Council directly with your request. |
| `/version` | Show the currently installed plugin version. |

---

## Installation

```bash
claude agent add jballaban/panel
```

**Agent teams (optional):** The finalization step uses agent teams if available. Requires Claude Code v2.1.32+ and:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

Without it, finalization runs as parallel subagents instead.

---

## How it works

1. **Propose** — Elrond analyzes your request and recommends who should sit at the table: named roles like UX Designer, API Specialist, Security Engineer
2. **Assemble** — You choose how many seats and confirm the roster. Swap anyone or add your own
3. **Deliberate** — Council members analyze in parallel. Each returns structured findings with severity
4. **Consolidate** — Elrond merges the findings; Gandalf checks the result for coherence
5. **Review** — You see a summary and decide: accept, redirect, or read the full notes first
6. **Finalize** — The council reconvenes to validate and rate the final response
7. **Deliver** — The answer, plus a confidence rating from each council member (🟢 🟡 🔴)

---

## What the Council is not

The council produces analysis and recommendations — not code. Use its output to inform your own decisions or pass it to an implementation agent.
