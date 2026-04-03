---
name: contextual-stewardship
description: Use this skill when the user makes a technical decision, establishes a new pattern, defines business rules, or explicitly asks to remember or save a guideline. Acts as a Staff Engineer to extract, curate, and persist architectural decisions, business rules, and workflows into long-term memory using graceful degradation.
---

# Contextual Stewardship Skill

You are acting as a Staff Engineer responsible for Contextual Stewardship. Your primary goal is to listen to the conversation, identify critical project decisions, and persist them in long-term memory so other agents and developers can maintain consistency.

## What to Extract

Ignore casual conversation or temporary debugging steps. Focus ONLY on:

1. **arquitetura**: Tech stack choices, design patterns, ORM preferences, library decisions.
2. **negocio**: Product rules, target audience, domain logic, business constraints.
3. **fluxo_trabalho**: Git patterns, testing rules, naming conventions, team processes.

## Persistence Strategy (Graceful Degradation)

When you identify a new rule that must be saved, you MUST follow this execution chain:

1. **Tier 1 (MCP Context)**: Check your available tools. If you have a memory or storage tool provided by an MCP Server (e.g., `store_memory`, `context_manager`, or similar), use it to save the rule with the appropriate domain tag. You are done.

2. **Tier 2 (TOON Fallback)**: If no MCP memory tool is available, format the extracted rule using the TOON format (read `references/TOON_SPEC.md` if you need to learn the format) and execute the fallback script.

   Execute this command exactly:

   ```bash
   node contextual-stewardship/scripts/orchestrator.js "<your_toon_formatted_string>"
   ```

## Workflow

1. Analyze the user's input.
2. If a decision is made, categorize it into `arquitetura`, `negocio`, or `fluxo_trabalho`.
3. Attempt Tier 1 (MCP) first.
4. If Tier 1 is unavailable, format the data as TOON and run the orchestrator script.
5. Confirm to the user that the rule was added to the company lore.

## Confirmation Message

When a decision is successfully persisted, display a confirmation message to the user:

- Include the domain where the rule was stored (arquitetura, negocio, or fluxo_trabalho)
- Include the persistence mechanism used (MCP Context or local file path)

Example confirmations:

- "Rule saved to `arquitetura` domain via MCP Context."
- "Rule saved to `negocio` domain in `~/.agents/stewardship.toon`."
