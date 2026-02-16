# Agent Skills

A collection of reusable [Agent Skills](https://agentskills.io) for AI-powered development tools.

## What are Agent Skills?

Agent Skills are folders of instructions, scripts, and resources that give AI agents new capabilities and expertise. They help agents perform tasks more accurately and efficiently by providing domain-specific knowledge on demand.

These skills are compatible with tools like [Claude Code](https://claude.ai/code), [Cursor](https://cursor.com), [OpenCode](https://opencode.ai), [Gemini CLI](https://geminicli.com), and [many others](https://agentskills.io).

## Available Skills

| Skill | Description |
|-------|-------------|
| [bootstrap-5](./bootstrap-5) | Build modern, responsive, accessible web interfaces using pure Bootstrap 5. Covers grid system, flexbox utilities, spacing, colors, typography, forms, buttons, cards, modals, navbars, and more. |

## Installation

Copy the skill folder to your project or skills directory:

```bash
# Clone or download this repository
git clone https://github.com/yourusername/my-agent-skills.git

# Copy a skill to your project
cp -r my-agent-skills/bootstrap-5 ./skills/
```

Alternatively, configure your agent tool to point to this repository as a skills source.

## Usage

Once installed, compatible AI agents will automatically discover these skills and use them when relevant to your task. Simply ask your agent to help with something covered by a skill, and it will load the appropriate context.

For example, with the `bootstrap-5` skill installed:

```
"Create a responsive card layout with a navbar using Bootstrap 5"
```

The agent will use the skill's instructions to write proper Bootstrap markup.

## Creating Your Own Skills

To create a new skill, create a folder with a `SKILL.md` file containing YAML frontmatter and instructions:

```markdown
---
name: my-skill
description: What this skill does and when to use it.
---

# Instructions

Your detailed instructions for the agent here.
```

See the [Agent Skills Specification](https://agentskills.io/specification) for the complete format.

## Resources

- [Agent Skills Documentation](https://agentskills.io/home)
- [Specification](https://agentskills.io/specification)
- [Example Skills](https://github.com/anthropics/skills)
- [Reference Library](https://github.com/agentskills/agentskills/tree/main/skills-ref)

## License

Each skill has its own license specified in the `SKILL.md` frontmatter. See individual skill folders for details.
