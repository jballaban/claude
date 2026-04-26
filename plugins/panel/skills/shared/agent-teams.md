# Agent Teams Reference

Source: https://code.claude.com/docs/en/agent-teams

Agent teams let multiple Claude Code instances work together as a coordinated team. Unlike subagents (which only report back to the main agent), teammates can communicate directly with each other.

> **Status:** Experimental — requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in settings.json or environment. Requires Claude Code v2.1.32+.

---

## Architecture

| Component | Role |
|-----------|------|
| **Team lead** | The main Claude Code session that creates the team, spawns teammates, and coordinates work |
| **Teammates** | Separate Claude Code instances, each with their own context window |
| **Task list** | Shared list of work items teammates claim and complete; supports dependencies |
| **Mailbox** | Messaging system — teammates send messages directly to each other by name |

**Key capability:** Any teammate can message any other teammate directly. The lead does not need to mediate every exchange. Messages are delivered automatically.

---

## Subagents vs Agent Teams

| | Subagents | Agent Teams |
|--|-----------|-------------|
| **Communication** | Report results back to main agent only | Teammates message each other directly |
| **Coordination** | Main agent manages all work | Shared task list with self-coordination |
| **Best for** | Focused tasks where only the result matters | Work requiring discussion and collaboration |
| **Token cost** | Lower | Higher — each teammate is a separate Claude instance |

**Use subagents when:** workers don't need to talk to each other and only the result matters.
**Use agent teams when:** teammates need to share findings, challenge each other, and coordinate on their own.

---

## How Teams Work in Practice

### Spawning
Tell Claude (the lead) to create a team and describe the structure in natural language:
```
Create an agent team with three reviewers: one on security, one on performance,
one playing devil's advocate. Have them challenge each other's findings.
```

### Direct teammate messaging
Teammates can send messages to each other by name. The lead assigns names at spawn time.
To get predictable names, specify them in the spawn instruction.

### Task list
- Lead creates tasks; teammates claim and complete them
- Task dependencies are resolved automatically — a blocked task unblocks when its dependency completes
- File locking prevents race conditions when multiple teammates try to claim the same task

### Using subagent definitions as teammates
Teammates can be based on existing subagent/skill definitions:
```
Spawn a teammate using the security-reviewer agent type to audit the auth module.
```
The definition's body is appended to the teammate's system prompt. The definition's `tools` allowlist and `model` are honored. Team coordination tools (`SendMessage`, task tools) are always available regardless of `tools` restrictions.

---

## Deliberation Pattern

From the docs — the debate structure for competing hypotheses:
```
Spawn 5 agent teammates to investigate different hypotheses. Have them talk to
each other to try to disprove each other's theories, like a scientific debate.
Update the findings doc with whatever consensus emerges.
```

**Why this works:** Sequential investigation anchors on the first theory found. Independent agents actively trying to disprove each other produce a theory that survives adversarial scrutiny.

---

## Key Constraints

- **Experimental** — known limitations around session resumption, task coordination, shutdown
- **One team per session** — a lead can only manage one team at a time
- **No nested teams** — teammates cannot spawn their own teams; only the lead can
- **No session resumption** — `/resume` and `/rewind` do not restore in-process teammates
- **Permissions set at spawn** — all teammates start with the lead's permission mode
- **Token cost scales linearly** — each teammate has its own context window
- **Recommended team size** — 3–5 teammates; 5–6 tasks per teammate
- **Task status can lag** — teammates sometimes fail to mark tasks complete; may need nudging

---

## Enabling

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

---

## Relevance to Panel Pipeline

Agent teams are the right mechanism for **Phase 3 deliberation** (validation round):
- Phase 1 (parallel analysis): use **subagents** — independent signal, no anchoring bias
- Phase 3 (deliberation): use **agent teams** — teammates can challenge each other directly, converge on alignment rating
- The "one team per session" constraint is not a problem: Phase 1 uses subagents, so Phase 3 can be the one team
- The adversarial agent becomes a teammate whose specific role is to resist easy consensus
