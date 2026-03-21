# Agent Skills

A collection of reusable [Agent Skills](https://agentskills.io) for AI-powered development tools.

## What are Agent Skills?

Agent Skills are folders of instructions, scripts, and resources that give AI agents new capabilities and expertise. They help agents perform tasks more accurately and efficiently by providing domain-specific knowledge on demand.

These skills are compatible with tools like [Claude Code](https://claude.ai/code), [Cursor](https://cursor.com), [OpenCode](https://opencode.ai), [Gemini CLI](https://geminicli.com), and [many others](https://agentskills.io).

## Available Skills

| Skill | Description |
|-------|-------------|
| [admin-ui-svelte](./admin-ui-svelte) | Build modern admin dashboards with Tailwind CSS v4, Skeleton UI, and Svelte 5. Covers layouts, tables, forms, navigation, auth pages, and responsive design patterns. |
| [bootstrap-5](./bootstrap-5) | Build modern, responsive, accessible web interfaces using pure Bootstrap 5. Covers grid system, flexbox utilities, spacing, colors, typography, forms, buttons, cards, modals, navbars, and more. |
| [sequential-thinking](./sequential-thinking) | Structured reasoning for complex problems. Use for multi-step reasoning, architectural decisions, debugging unclear root causes, or tasks where problem scope is uncertain. |

## Installation

Copy the skill folder to your project or skills directory:

```bash
# Clone or download this repository
git clone https://github.com/yourusername/my-agent-skills.git

# Copy a skill to your project
cp -r my-agent-skills/admin-ui-svelte ./skills/
```

Alternatively, configure your agent tool to point to this repository as a skills source.

## Usage

Once installed, compatible AI agents will automatically discover these skills and use them when relevant to your task. Simply ask your agent to help with something covered by a skill, and it will load the appropriate context.

Example prompts:

```
"Create a responsive admin dashboard with sidebar navigation"
"Build a login form with validation using Bootstrap 5"
"Help me debug this intermittent API failure"
```

## Creating Your Own Skills

To create a new skill, create a folder with a `SKILL.md` file containing YAML frontmatter and instructions:

```markdown
---
name: my-skill
description: What it does and when to use it.
---

# Instructions

Your detailed instructions for the agent here.
```

See the [Agent Skills Specification](https://agentskills.io/specification) for the complete format and [AGENTS.md](./AGENTS.md) for contributor guidelines.

## Resources

- [Agent Skills Documentation](https://agentskills.io/home)
- [Specification](https://agentskills.io/specification)
- [Best Practices](https://agentskills.io/skill-creation/best-practices)
- [Example Skills](https://github.com/anthropics/skills)
- [Reference Library](https://github.com/agentskills/agentskills/tree/main/skills-ref)

## License

Each skill has its own license specified in the `SKILL.md` frontmatter. See individual skill folders for details.