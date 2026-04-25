---
title: Skill Authoring Best Practices
source: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
---

## Core Principles

**Be concise.** The context window is shared. Every token in SKILL.md competes with conversation history. Only add what Claude doesn't already know. Challenge each line: "Does Claude need this?"

**Set appropriate degrees of freedom:**
- High freedom (text instructions): multiple valid approaches, context-dependent decisions
- Medium freedom (pseudocode/parameterized scripts): preferred pattern exists, some variation OK
- Low freedom (exact scripts, no params): fragile operations, consistency is critical

**Test with all models you plan to deploy.** Haiku may need more guidance; Opus needs less explanation. Aim for instructions that work across the tier you target.

---

## SKILL.md Structure

**Frontmatter requirements:**
- `name`: max 64 chars, lowercase letters/numbers/hyphens only, no XML tags, no "anthropic" or "claude"
- `description`: non-empty, max 1024 chars, no XML tags — written in **third person**

**Naming:** Use gerund form (`processing-pdfs`, `analyzing-spreadsheets`). Avoid vague names (`helper`, `utils`, `tools`).

**Description must answer two questions:** What does this skill do? When should it be triggered?

```yaml
# Good
description: Extracts text and tables from PDF files. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.

# Bad
description: Helps with documents
```

**Size limit:** Keep SKILL.md body under 500 lines. Split content into separate files and use progressive disclosure.

---

## Progressive Disclosure

SKILL.md is a table of contents. Load details only when needed.

```
skill/
├── SKILL.md          # overview + navigation (always loaded)
├── ADVANCED.md       # loaded only when needed
├── REFERENCE.md      # loaded only when needed
└── scripts/
    └── helper.py     # executed, not loaded into context
```

**Rules:**
- All reference files link directly from SKILL.md (one level deep only — avoid nested chains)
- Reference files >100 lines must include a table of contents at the top
- Use domain-organized subdirectories for multi-domain skills

---

## Content Guidelines

**Avoid time-sensitive information.** Don't write "use old API before Aug 2025." Use a `## Old Patterns` section with `<details>` tags for deprecated content.

**Use consistent terminology.** Pick one term and use it throughout: "API endpoint" not a mix of "URL", "route", "path".

**Avoid offering too many options.** Provide a default with a single escape hatch:
```
Use pdfplumber for text extraction.
For scanned PDFs requiring OCR, use pdf2image with pytesseract instead.
```

**Use forward slashes in all file paths** — Windows backslashes break on Unix.

**MCP tool references must be fully qualified:** `ServerName:tool_name` (e.g., `GitHub:create_issue`).

---

## Workflows and Feedback Loops

For complex tasks, provide a numbered checklist Claude can copy and track:

```markdown
Task Progress:
- [ ] Step 1: Analyze inputs
- [ ] Step 2: Create plan
- [ ] Step 3: Validate plan
- [ ] Step 4: Execute
- [ ] Step 5: Verify output
```

**Always include a validation loop for critical operations:**
1. Execute step
2. Validate with script or checklist
3. If failure: fix and repeat
4. Only proceed when validation passes

---

## Common Patterns

**Template pattern:** Provide exact structure for strict requirements; hint at structure for flexible tasks.

**Examples pattern:** Provide input/output pairs for tasks where format matters. Wrap in `<example>` tags.

**Conditional workflow pattern:** Branch based on task type:
```markdown
**Creating new content?** → Follow "Creation workflow"
**Editing existing content?** → Follow "Editing workflow"
```

---

## Executable Scripts

- Scripts are executed via bash — only their output consumes context tokens
- Be explicit: "Run `analyze.py`" (execute) vs "See `analyze.py` for the algorithm" (read)
- Handle errors explicitly in scripts — don't punt to Claude
- Document all constants (no magic numbers)
- List all required packages; don't assume they're installed

**Plan-validate-execute pattern** for batch/destructive operations:
1. Claude creates a structured plan file (e.g., `changes.json`)
2. Script validates the plan before any changes
3. Execute only after validation passes

---

## Development Process

**Build evaluations before writing extensive documentation.** Test gaps first, then write minimal instructions to address those gaps.

**Iterative development:**
1. Complete a task without a skill — notice what context you repeatedly provide
2. Ask Claude A to create a skill from that pattern
3. Test with Claude B (fresh instance with skill loaded)
4. Observe failures → return to Claude A with specifics → refine → retest

**Observe how Claude navigates:** Watch for missed file connections, ignored content, overreliance on one section — these signal structural issues.

---

## Pre-Release Checklist

- [ ] Description is specific, third-person, includes what + when
- [ ] SKILL.md body under 500 lines
- [ ] No time-sensitive information
- [ ] Consistent terminology
- [ ] Concrete examples (not abstract)
- [ ] File references max one level deep
- [ ] All scripts handle errors explicitly
- [ ] No Windows-style paths
- [ ] Required packages listed
- [ ] Tested with all target models
- [ ] At least three evaluations created
