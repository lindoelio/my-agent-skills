# Agent Skills Repository

This repository contains reusable [Agent Skills](https://agentskills.io) for AI-powered development tools like Claude Code, Cursor, and OpenCode.

## Repository Structure

```
/
├── SKILL_NAME/           # Each skill is a directory
│   ├── SKILL.md          # Required: Main skill file with frontmatter + instructions
│   ├── references/       # Optional: Additional documentation loaded on demand
│   ├── scripts/          # Optional: Executable code for the agent
│   └── assets/           # Optional: Templates and static resources
├── README.md             # Repository overview
└── AGENTS.md             # This file - guidelines for contributors
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

### Run Markdown Linter

```bash
# Using markdownlint-cli (if installed)
npx markdownlint-cli "**/*.md"

# Fix auto-fixable issues
npx markdownlint-cli "**/*.md" --fix
```

### Git Workflow

```bash
# Check for issues before committing
git status
git diff

# Commit with descriptive message
git add .
git commit -m "feat: add new skill for X"
```

## Skill Creation Guidelines

### SKILL.md Structure

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

### Naming Conventions

- **Skill names**: lowercase letters, numbers, hyphens only (e.g., `admin-ui-svelte`)
- **Must match directory name**: If folder is `admin-ui-svelte/`, name field must be `admin-ui-svelte`
- **No consecutive hyphens**: `my--skill` is invalid
- **Cannot start/end with hyphen**: `-skill` and `skill-` are invalid

### Description Best Practices

1. Use imperative phrasing: "Use this skill when..." not "This skill does..."
2. Include trigger contexts: specific task types, user intent, implicit scenarios
3. Add escape clauses: "even if the user doesn't explicitly mention X"
4. Stay under 1024 characters

### File Organization

- **SKILL.md**: Core instructions (< 500 lines, < 5000 tokens recommended)
- **references/**: Detailed documentation loaded on demand
- **scripts/**: Executable code (Python, Bash, JavaScript)
- **assets/**: Templates, schemas, static files

### Reference File Guidelines

- Keep files focused on a single topic
- Use descriptive names: `installation.md`, `api-errors.md`
- Tell the agent when to load: "Read `references/api-errors.md` if the API returns errors"
- Reference files from SKILL.md, not from other reference files

## Code Style

### Markdown Formatting

```markdown
# Use ATX-style headers (# ## ###)

## Sections

- Use hyphens for unordered lists
- Indent nested items with 2 spaces

### Code Blocks

Specify language for syntax highlighting:

```svelte
<script>
  let count = $state(0);
</script>
```

### Use fenced code blocks, not indented
```

### YAML Frontmatter

- Quote string values with special characters
- Use consistent indentation (2 spaces)
- Order fields: name, description, license, compatibility, metadata, allowed-tools

### Skill Content

1. **Gotchas section**: High-value, add near the top
2. **Quick start**: Working example within first 50 lines
3. **Progressive disclosure**: Core instructions in SKILL.md, details in references/
4. **No redundancy**: Skip what agents already know (e.g., "what is a PDF")

## Validation Checklist

Before submitting a new skill:

- [ ] SKILL.md exists with valid YAML frontmatter
- [ ] `name` matches directory name
- [ ] `description` is under 1024 characters
- [ ] `name` is lowercase with hyphens only
- [ ] SKILL.md is under 500 lines
- [ ] Markdown syntax is valid
- [ ] Reference files are in `references/` directory
- [ ] File paths in references are relative

## Resources

- [Agent Skills Specification](https://agentskills.io/specification)
- [Best Practices](https://agentskills.io/skill-creation/best-practices)
- [Optimizing Descriptions](https://agentskills.io/skill-creation/optimizing-descriptions)
- [skills-ref CLI](https://github.com/agentskills/agentskills/tree/main/skills-ref)