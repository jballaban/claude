---
title: Prompt Engineering Best Practices
source: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices
---

## General Principles

**Be clear and direct.** Claude is a brilliant new employee with no context on your norms. Specify desired output format, constraints, and steps explicitly. Use the golden rule: if a colleague with minimal context would be confused by your prompt, Claude will be too.

**Add context/motivation.** Explain *why* a behavior matters — Claude generalizes from the explanation, not just the rule.
```
# Bad
NEVER use ellipses

# Good
Never use ellipses — this text will be read by a TTS engine that can't pronounce them.
```

**Use examples.** Few-shot prompting is one of the most reliable steering mechanisms. 3–5 examples that are relevant, diverse, and wrapped in `<example>` tags work best.

**Structure with XML tags.** Wrap instructions, context, examples, and inputs in their own tags (`<instructions>`, `<context>`, `<input>`) to eliminate ambiguity.

**Give Claude a role.** A single sentence in the system prompt shapes tone and focus: `"You are a helpful coding assistant specializing in Python."`

---

## Long Context (20k+ tokens)

- **Put long documents first**, above your query and instructions — can improve quality by up to 30%
- Wrap each document in `<document index="N"><source>...</source><document_content>...</document_content></document>` tags
- Ask Claude to extract relevant quotes before reasoning — grounds the response and reduces hallucination

---

## Output and Formatting

**Tell Claude what to do, not what to avoid:**
- Instead of "Don't use markdown" → "Write in smoothly flowing prose paragraphs."

**Match your prompt style to your desired output style.** Markdown-heavy prompts produce markdown-heavy outputs.

**For verbosity control:**
```
Provide concise, focused responses. Skip non-essential context, keep examples minimal.
```

**For structured output:** Use the Structured Outputs feature or XML tags — newer models reliably match complex schemas when asked.

**To eliminate preambles:** `"Respond directly without preamble. Do not start with 'Here is...', 'Based on...' etc."`

---

## Tool Use

**Be explicit about action vs. suggestion:**
- "Can you suggest changes?" → Claude will suggest
- "Change this function to improve performance." → Claude will act

**For proactive action by default:**
```xml
<default_to_action>
By default, implement changes rather than only suggesting them. If intent is unclear, infer the most useful action and proceed, using tools to discover missing details.
</default_to_action>
```

**For conservative behavior:**
```xml
<do_not_act_before_instructions>
Do not jump into implementation unless clearly instructed. Default to providing information and recommendations when intent is ambiguous.
</do_not_act_before_instructions>
```

**Maximize parallel tool calls** for independent operations:
```xml
<use_parallel_tool_calls>
Make all independent tool calls in parallel. Never use placeholders or guess missing parameters.
</use_parallel_tool_calls>
```

---

## Thinking and Reasoning

**Use adaptive thinking** (`thinking: {type: "adaptive"}`) for agentic/multi-step work. Use the `effort` parameter to control depth:
- `xhigh`: best for coding and agentic use cases
- `high`: minimum for most intelligence-sensitive use cases
- `medium`: cost-sensitive with some quality tradeoff
- `low`: latency-sensitive, scoped tasks only

**Set max output tokens generously** at high effort — recommend starting at 64k for Opus 4.7.

**Guide thinking behavior:**
```
After receiving tool results, reflect on their quality and determine optimal next steps before proceeding.
```

**Prevent overthinking:**
```
Thinking should only be used when it will meaningfully improve quality — typically for multi-step reasoning. When in doubt, respond directly.
```

**Prevent overengineering:**
```
Only make changes directly requested or clearly necessary. Don't add features, refactor, or create abstractions beyond what was asked.
```

---

## Agentic Systems

**Context window management:**
```
Your context will be automatically compacted as it approaches its limit. Do not stop tasks early due to token budget concerns. Save progress state before context refreshes.
```

**State management:**
- Structured formats (JSON) for trackable state (test results, task status)
- Freeform text for progress notes
- Git for session-to-session state tracking

**Autonomy and safety — require confirmation for risky actions:**
```
Consider reversibility before acting. Confirm before: deleting files/branches, git push --force, posting to external services, modifying shared infrastructure.
```

**Prevent hallucinations in codebases:**
```xml
<investigate_before_answering>
Never speculate about code you have not opened. Read relevant files BEFORE answering questions. Never make claims about code without investigating first.
</investigate_before_answering>
```

**Subagent guidance:**
```
Use subagents when tasks can run in parallel or require isolated context. Work directly for single-file edits, sequential operations, and tasks requiring shared state.
```

---

## Model-Specific Notes

**Claude Opus 4.7:**
- More literal instruction following — state scope explicitly ("apply this to every section, not just the first")
- Fewer tools by default — use `xhigh` effort or explicit tool instructions to increase usage
- Spawns fewer subagents by default — steer with explicit guidance when needed
- Better at finding bugs — prompt for coverage over filtering at the finding stage

**Claude Sonnet 4.6:**
- Default effort is `high` — set explicitly to `medium` or `low` for cost/latency control
- Prefer adaptive thinking over budget_tokens (deprecated)
- Set 64k max_tokens at medium/high effort

**All models:**
- Positive examples of correct behavior outperform negative instructions about what not to do
- At `low` effort, be explicit about multi-step reasoning requirements
