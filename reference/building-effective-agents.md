---
title: Building Effective Agents
source: https://www.anthropic.com/engineering/building-effective-agents
---

## Core Principle

**Start simple.** Many tasks are solved by a single well-prompted LLM call with retrieval and examples. Only add agentic complexity when simpler approaches demonstrably underperform. "Success isn't about building the most sophisticated system — it's about building the right system for your needs."

---

## Workflows vs. Agents

**Workflows:** LLMs orchestrated through predefined code paths. Predictable, auditable, lower error surface.

**Agents:** LLMs dynamically direct their own process and tool usage. Use when problems are open-ended, step counts can't be pre-defined, and hardcoded paths are impossible.

---

## Workflow Patterns

### Prompt Chaining
Sequential steps with programmatic gates between them.
- **Use when:** fixed subtasks, accuracy matters more than latency
- **Structure:** step 1 → validate → step 2 → validate → ...

### Routing
Classify input, direct to specialized downstream processes.
- **Use when:** complex tasks with distinct categories requiring different handling

### Parallelization
Run independent subtasks simultaneously, or run identical tasks multiple times for voting.
- **Sectioning:** split independent subtasks across parallel workers
- **Voting:** run same task N times, take majority result for high-stakes decisions
- **Use when:** speed matters or multiple perspectives improve confidence

### Orchestrator-Workers
Central LLM dynamically breaks down tasks and delegates to workers, then synthesizes.
- **Use when:** subtasks can't be pre-defined, problem space is unpredictable
- This is the primary pattern for complex agent systems

### Evaluator-Optimizer
One LLM generates, another evaluates in a feedback loop.
- **Use when:** clear evaluation criteria exist, iterative refinement is measurable

---

## When to Use Each Pattern

```
Is the task open-ended with unpredictable steps?
├── Yes → Agent (Orchestrator-Workers)
└── No → Workflow
    ├── Fixed sequence → Prompt Chaining
    ├── Multiple input types → Routing
    ├── Independent subtasks → Parallelization
    └── Quality-critical output → Evaluator-Optimizer
```

---

## Tool Design (Agent-Computer Interface)

This is where most agent performance gains come from. Invest more time in tool design than in overall prompt tuning.

**Best practices:**
- Write clear descriptions with examples, edge cases, and clear boundaries between similar tools
- Think like a junior developer reading the tool docs for the first time — if it seems unclear to you, it is to the model too
- Apply poka-yoke principles: redesign parameters to make errors harder (e.g., absolute filepaths prevent relative path mistakes)
- Test extensively with varied inputs before deploying
- Allocate sufficient tokens for the model to "think" before executing tool calls

**Format selection:**
- Keep formats aligned with naturally occurring internet text patterns
- Eliminate unnecessary formatting overhead (avoid accurate line counting, string escaping, etc.)

---

## Agent Design Principles

**Transparency:** Display planning steps and decision-making processes. Don't let the agent be a black box.

**Control:** Implement stopping conditions. Agents have autonomous action and can compound errors — guardrails are mandatory.

**Ground truth at each step:** The agent must receive environmental feedback after each action (not just at the end).

**Error recovery:** Agents must handle partial failures gracefully without human intervention.

**Sandboxed testing:** Conduct extensive testing in sandboxed environments before production. Autonomous agents can cause hard-to-reverse damage.

---

## Framework Guidance

Common frameworks: Claude Agent SDK, Strands Agents SDK, Rivet, Vellum.

**Recommendation:** Start by using LLM APIs directly. Most patterns require only a few lines of code. If you use a framework, understand the underlying implementation — incorrect assumptions about framework behavior are a leading source of agent bugs.

---

## Practical Applications

**Customer support:** Natural fit — conversation flows + tool integration for retrieval, knowledge lookup, and programmatic actions. Success measurable via resolution rate.

**Coding agents:** Verifiable via automated tests. Agents iterate using test feedback. Human review remains important for architectural decisions.

---

## Anti-Patterns

- Adding agentic layers before demonstrating that simpler approaches fail
- Black-box agents with no visible planning or reasoning
- No validation/feedback loops between steps
- Relative filepaths and other parameter designs that make errors easy
- No stopping conditions or confirmation gates for irreversible actions
- Deploying agents to production without sandboxed testing
- Frameworks used as a shortcut to understanding

---

## Measurement

Measure performance continuously at every layer. Only add complexity when it demonstrably improves outcomes over the baseline. Track: accuracy, latency, cost per task completion, error rate, and recovery rate.
