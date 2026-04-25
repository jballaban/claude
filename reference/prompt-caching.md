---
title: Prompt Caching
source: https://platform.claude.com/docs/en/build-with-claude/prompt-caching
---

## How It Works

On a cache miss: the full prompt is processed and the prefix up to the marked breakpoint is cached.
On a cache hit: the cached prefix is reused — processing time and cost drop to ~10% of normal input cost.

Cache is refreshed (at no cost) whenever it's used. Default TTL is 5 minutes; 1-hour TTL is available.

**Minimum cacheable length:**
- Opus 4.7 / 4.6 / 4.5, Haiku 4.5: **4096 tokens**
- Sonnet 4.6: **2048 tokens**
- Sonnet 4.5 / 4, Opus 4.1 / 4: **1024 tokens**

Shorter prompts cannot be cached (no error returned — check `usage` fields to confirm caching).

---

## Two Implementation Approaches

### Automatic Caching (recommended for most cases)

Add `cache_control` at the **top level** of the request. The breakpoint is placed automatically on the last cacheable block.

```python
response = client.messages.create(
    model="claude-opus-4-7",
    max_tokens=1024,
    cache_control={"type": "ephemeral"},
    system="You are an AI assistant...",
    messages=[{"role": "user", "content": "..."}],
)
```

Best for: growing conversations, simple setups, cases where the prefix is always "everything so far."

### Explicit Cache Breakpoints

Place `cache_control` directly on individual content blocks.

```python
system=[
    {"type": "text", "text": "Core instructions"},
    {"type": "text", "text": "Large document content here...",
     "cache_control": {"type": "ephemeral"}},  # breakpoint after stable content
]
```

Best for: content that changes at different frequencies, 20+ block conversations where auto-caching misses.

---

## Critical Rule: Breakpoint Placement

**Place `cache_control` on the last block whose prefix is identical across requests.**

If the breakpoint is on content that changes every request (timestamps, per-request messages), you'll get zero cache hits.

```python
# Wrong: breakpoint on changing content
{"type": "text", "text": f"Query: {user_message}", "cache_control": {"type": "ephemeral"}}

# Correct: breakpoint after stable content, changing content follows without cache_control
{"type": "text", "text": "All my static examples end here", "cache_control": {"type": "ephemeral"}},
{"type": "text", "text": f"Query: {user_message}"}  # no cache_control
```

---

## TTL Options

### 5-Minute (default)
- No additional cost
- Auto-refreshed when hit
- Use for: prompts accessed multiple times within 5 minutes

### 1-Hour
```python
cache_control={"type": "ephemeral", "ttl": "1h"}
```
- Costs 2× base input price (vs 1.25× for 5-min)
- Use for: prompts used less than every 5 min but more than hourly
- Benefits: better latency for large documents, better rate limit utilization

### Mixing TTLs
1-hour entries must appear before 5-minute entries in the same request.

---

## Pricing

| Model | Base Input | 5m Cache Write | 1h Cache Write | Cache Hit | Output |
|-------|-----------|----------------|----------------|-----------|--------|
| Opus 4.7 | $5/MTok | $6.25/MTok | $10/MTok | $0.50/MTok | $25/MTok |
| Sonnet 4.6 | $3/MTok | $3.75/MTok | $6/MTok | $0.30/MTok | $15/MTok |
| Haiku 4.5 | $1/MTok | $1.25/MTok | $2/MTok | $0.10/MTok | $5/MTok |

Cache hits are **10% of base input price** — a 90% cost reduction on cached tokens.

**Break-even point for 5-min cache:** content accessed more than once within 5 minutes pays back the 1.25× write premium.

---

## What to Cache

**High-value candidates (place breakpoints after these):**
- Tool definitions (large sets)
- System prompt + background context
- Few-shot examples (especially 20+ examples)
- Large documents being analyzed across multiple queries

**Cannot be directly cached:**
- Thinking blocks (but they cache as part of previous assistant turns)
- Sub-content blocks like citations

---

## Cache Invalidation

Changes at each level invalidate that level and everything after it:

| Change | Invalidates |
|--------|-------------|
| Tool definitions changed | Tools + System + Messages |
| Web search / citations toggled | System + Messages (tools preserved) |
| Tool choice changed | Messages only |
| Image in system changed | Messages only |
| Thinking parameters changed | Messages only |

---

## Prompt Structure for Maximum Cache Hits

Order content from most stable to most dynamic:

```
1. Tool definitions          ← most stable, cache here
2. System instructions
3. Background context / docs ← cache here if large
4. Examples                  ← cache here if many
5. Conversation history
6. Current user message      ← most dynamic, never cache here
```

---

## Monitoring Cache Performance

```python
print(response.usage)
# cache_creation_input_tokens: written to cache this request
# cache_read_input_tokens: read from cache this request
# input_tokens: processed without caching (after last breakpoint)
```

**Debugging cache misses:**
- Verify prompt meets minimum token length
- Confirm `cache_read_input_tokens > 0` on second request
- Check that requests arrive within the TTL window
- Verify prefix content is bit-for-bit identical across requests
- Confirm breakpoint is on unchanging content

---

## Application Patterns

**Multi-turn conversations:** Use automatic caching (`cache_control` at request level). Breakpoint moves forward automatically as conversation grows.

**Large document Q&A:** Cache the full document in system context. Each new question pays only for question tokens + output.

**Tool-heavy agents:** Cache tool definitions. Large tool sets are expensive to re-process every turn.

**High-example prompts:** Cache 20+ examples. This is one of the highest-ROI caching applications.

**Agent system prompts:** Always cache agent role definitions and core instructions — they're identical across every turn.
