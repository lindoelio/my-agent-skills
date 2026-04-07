# Agent Skills Repository

This repository contains reusable [Agent Skills](https://agentskills.io) for AI-powered development tools like Claude Code, Cursor, and OpenCode.

## Repository Structure

```
/
├── SKILL_NAME/              # Each skill is a directory
│   ├── SKILL.md             # Required: Main skill file with frontmatter + instructions
│   ├── references/          # Optional: Additional documentation loaded on demand
│   ├── scripts/             # Optional: Executable code for the agent
│   └── assets/              # Optional: Templates and static resources
├── README.md                # Repository overview
└── AGENTS.md                # This file - guidelines for contributors
```

## Commands

### Validate Skills

```bash
# Install the skills-ref CLI (one-time)
npm install -g @agentskills/skills-ref

# Validate a single skill
skills-ref validate ./admin-ui-svelte

# Validate all skills
skills-ref validate ./*/SKILL.md
```

### Markdown Linting

```bash
# Run markdownlint-cli (if installed)
npx markdownlint-cli "**/*.md"

# Fix auto-fixable issues
npx markdownlint-cli "**/*.md" --fix
```

### Git Workflow

```bash
# Check status before committing
git status
git diff

# Commit with descriptive message (conventional commits)
git add .
git commit -m "feat: add new skill for X"
```

## SKILL.md Structure

Every skill must have a `SKILL.md` with YAML frontmatter:

```markdown
---
name: skill-name              # Required: lowercase, hyphens only, max 64 chars
description: What it does.    # Required: max 1024 chars, use imperative phrasing
license: MIT                  # Optional: license name or file reference
compatibility: Requires X     # Optional: max 500 chars
metadata:                     # Optional: arbitrary key-value pairs
  author: name
  version: "1.0"
allowed-tools: Bash(git:*)    # Optional: pre-approved tools
---

# Skill Title

Instructions for the agent here.
```

## Naming Conventions

| Element | Rule | Example |
|---------|------|---------|
| Skill names | lowercase, numbers, hyphens only | `admin-ui-svelte` |
| Directory | Must match `name` field | `admin-ui-svelte/SKILL.md` |
| No consecutive hyphens | `my--skill` is invalid | - |
| No leading/trailing hyphens | `-skill` and `skill-` are invalid | - |

## YAML Frontmatter

- Quote string values with special characters
- Use 2-space indentation consistently
- Field order: `name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools`
- The `name` field MUST match the directory name exactly
- Keep `description` under 1024 characters

## Markdown Style

### Headers

- Use ATX-style headers (`# ## ###`)
- One H1 per file (the skill title)
- Logical hierarchy: H1 → H2 → H3 → H4 (no skipping levels)
- No header text styling (no bold/italic in headers)

### Lists

- Use hyphens for unordered lists
- Indent nested items with 2 spaces
- Keep list items concise; complex content belongs in paragraphs or code blocks
- Use blank lines to separate related lists from paragraphs

### Code Blocks

- Always specify language for syntax highlighting
- Use fenced code blocks (triple backticks), never indented code
- Keep code examples short and focused (extract long examples to reference files)

```svelte
<script>
  let count = $state(0);
</script>
```

### Links

- Use relative paths for internal references: `[Installation](references/installation.md)`
- Use descriptive link text (not "click here")

## Content Guidelines

1. **Gotchas section** (recommended near top): High-value warnings and common mistakes
2. **Quick start**: Working example within first 50 lines
3. **Progressive disclosure**: Core instructions in SKILL.md, details in `references/`
4. **No redundancy**: Skip what agents already know (e.g., "what is a PDF")
5. **No comments in code examples**: Omit explanatory comments unless critical

## Reference Files

- Keep files focused on a single topic
- Use descriptive names: `installation.md`, `api-errors.md`
- Tell agents when to load: "Read `references/api-errors.md` if the API returns errors"
- Reference files from SKILL.md, not from other reference files
- All paths in reference files must be relative

## File Organization

| File | Recommendation |
|------|----------------|
| SKILL.md | < 500 lines, < 5000 tokens |
| references/*.md | < 1000 lines each |
| scripts/* | Executable: Python, Bash, JavaScript |
| assets/* | Templates, schemas, static files |

## Validation Checklist

Before submitting a new skill:

- [ ] SKILL.md exists with valid YAML frontmatter
- [ ] `name` matches directory name exactly
- [ ] `description` is under 1024 characters
- [ ] `name` is lowercase with hyphens only, no consecutive/leading/trailing hyphens
- [ ] SKILL.md is under 500 lines
- [ ] Markdown syntax is valid (headers, lists, code blocks, links)
- [ ] Reference files are in `references/` directory
- [ ] All paths in references are relative
- [ ] No dead links

## Description Best Practices

1. Use imperative phrasing: "Use this skill when..." not "This skill does..."
2. Include trigger contexts: specific task types, user intent, implicit scenarios
3. Add escape clauses: "even if the user doesn't explicitly mention X"
4. Mention specific technologies/patterns covered

## Error Handling in Scripts

When writing executable scripts:

- Exit with code 0 on success, non-zero on failure
- Print meaningful error messages to stderr
- Handle missing dependencies gracefully with clear instructions
- Use `set -e` for bash scripts to fail on first error

## Resources

- [Agent Skills Specification](https://agentskills.io/specification)
- [Best Practices](https://agentskills.io/skill-creation/best-practices)
- [Optimizing Descriptions](https://agentskills.io/skill-creation/optimizing-descriptions)
- [skills-ref CLI](https://github.com/agentskills/agentskills/tree/main/skills-ref)
