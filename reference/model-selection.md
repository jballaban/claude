---
title: Model Selection Guide
source: https://platform.claude.com/docs/en/about-claude/models/choosing-a-model
---

## Selection Criteria

Evaluate three dimensions before choosing:
1. **Capabilities** — what features does the task require?
2. **Speed** — how quickly must the model respond?
3. **Cost** — what are the budget constraints for development and production?

---

## Model Tiers

| Model | Best For | Example Use Cases |
|-------|----------|-------------------|
| **Claude Opus 4.7** | Most capable; long-horizon agentic work, complex reasoning, advanced coding | Large-scale refactoring, multi-hour autonomous tasks, deep research, complex systems engineering |
| **Claude Sonnet 4.6** | Frontier intelligence at scale; coding, agents, enterprise workflows | Code generation, data analysis, content creation, visual understanding, agentic tool use |
| **Claude Haiku 4.5** | Near-frontier performance; fast, economical, extended thinking available | Real-time applications, high-volume processing, cost-sensitive deployments, sub-agent tasks |

**Current model IDs:**
- `claude-opus-4-7`
- `claude-sonnet-4-6`
- `claude-haiku-4-5-20251001`

---

## Decision Approach

### Option A: Start cheap, upgrade if needed
1. Begin with Claude Haiku 4.5
2. Test thoroughly
3. Upgrade only for specific capability gaps

**Best when:** prototyping, tight latency requirements, high volume, straightforward tasks

### Option B: Start capable, optimize down
1. Implement with Claude Opus 4.7
2. Optimize prompts
3. Downgrade to Sonnet or Haiku as workflow matures

**Best when:** complex reasoning, scientific/math tasks, accuracy outweighs cost, advanced coding

---

## Agent Role → Model Mapping

Use this as a starting point — benchmark against your actual task:

| Agent Role | Recommended Model | Rationale |
|------------|------------------|-----------|
| Orchestrator / planner | Opus 4.7 or Sonnet 4.6 | Needs strong reasoning, handles ambiguity |
| Developer / coder | Opus 4.7 | Best coding recall and precision |
| Analyst / researcher | Opus 4.7 or Sonnet 4.6 | Multi-source synthesis, long context |
| Sub-agents (parallelized workers) | Haiku 4.5 | High volume, fast, cost-efficient |
| QA / validator | Sonnet 4.6 | Good eval capabilities at lower cost |
| Simple routing / classification | Haiku 4.5 | Speed matters, task is scoped |

---

## Evaluation Process

1. Create benchmark tests specific to your use case (this is the most important step)
2. Test with your actual prompts and data
3. Compare across models:
   - Response accuracy
   - Output quality
   - Edge case handling
4. Weigh performance vs. cost tradeoffs

---

## Cost and Speed Context

For latency-sensitive paths, Haiku 4.5 is the default choice. For Opus 4.6, fast mode (beta) offers up to 2.5× higher output speed at premium pricing.

Cache read tokens cost ~10% of base input price across all models — heavily repetitive workloads benefit significantly from caching regardless of model tier (see `prompt-caching.md`).
