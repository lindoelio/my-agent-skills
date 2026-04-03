# Requirements

## Overview

The Contextual Stewardship AgentSkill enables AI agents to act as Staff Engineers by monitoring conversations, extracting architectural decisions and business rules, and persisting them to long-term memory. The skill uses a graceful degradation strategy: first attempting to use MCP Context tools, and falling back to local filesystem storage in TOON format.

This skill reduces context token overhead by storing decisions externally, ensures consistency across team members and agent sessions, and provides a searchable memory layer for future development work.

## Glossary

| Term | Definition |
|------|------------|
| TOON | Token-Oriented Object Notation - a flat, token-efficient data format for structured memory storage |
| Graceful Degradation | System design pattern where each tier provides reduced functionality if higher tiers are unavailable |
| Staff Engineer | Senior technical role responsible for architectural decisions and technical governance |
| MCP Context | Model Context Protocol - standard interface for providing memory tools to AI agents |
## Assumptions

- The agent using this skill has access to a terminal or shell environment
- Node.js runtime is available for executing the orchestrator script
- The user's workspace is a software development project where architectural decisions evolve over time
- Decisions extracted are intended for shared team knowledge, not private agent notes

## Requirements

### REQ-1: Decision Extraction

**User Story:** As an AI agent, I want to identify and extract architectural decisions, business rules, and workflow patterns from user conversations, so that I can preserve project knowledge for future reference.

#### Acceptance Criteria

1.1 WHEN the user makes a technical decision about tech stack, design patterns, or tooling, THEN the skill SHALL categorize the decision under the `arquitetura` domain.

1.2 WHEN the user specifies product scope, target audience, business rules, or domain logic, THEN the skill SHALL categorize the decision under the `negocio` domain.

1.3 WHEN the user establishes Git patterns, testing conventions, or naming standards, THEN the skill SHALL categorize the decision under the `fluxo_trabalho` domain.

1.4 IF the conversation contains only casual chat or temporary debugging steps, THEN the skill SHALL NOT extract or persist any data.

### REQ-2: Graceful Degradation Persistence

**User Story:** As an AI agent, I want to persist extracted decisions using the most reliable available method, so that context is never lost regardless of infrastructure availability.

#### Acceptance Criteria

2.1 THE skill SHALL attempt to use MCP Context memory tools as the first persistence option (Tier 1).

2.2 IF no MCP memory tools are available, THEN the skill SHALL persist data to a local `.toon` file (Tier 2).

2.3 THE skill SHALL execute persistence silently without requiring user intervention.

### REQ-3: TOON Format Output

**User Story:** As a developer, I want decisions stored in a token-efficient format, so that reading them later consumes minimal context tokens.

#### Acceptance Criteria

3.1 WHEN persisting to Tier 2 (local filesystem), THE skill SHALL format data using the TOON syntax defined in `references/TOON_SPEC.md`.

3.2 THE skill SHALL append new decision blocks to the existing `.toon` file without rewriting the entire file.

3.3 THE skill SHALL create the `.toon` file in the `~/.agents/` directory if it does not exist.

### REQ-4: Skill Structure

**User Story:** As an agent runtime, I want the skill delivered as a modular file structure, so that I can load only the components needed for each operation.

#### Acceptance Criteria

4.1 THE skill SHALL provide a `SKILL.md` file containing the main manifest with YAML frontmatter and behavior instructions.

4.2 THE skill SHALL provide a `references/TOON_SPEC.md` file containing the TOON syntax specification.

4.3 THE skill SHALL provide a `scripts/orchestrator.js` file containing the fallback persistence logic.

### REQ-5: Orchestrator Behavior

**User Story:** As a fallback mechanism, the orchestrator script SHALL persist data to local cold storage in TOON format, so that decisions are available for future sessions.

#### Acceptance Criteria

5.1 WHEN executed with valid TOON content, THE orchestrator SHALL append the content to `~/.agents/stewardship.toon`.

5.2 THE orchestrator SHALL create the `~/.agents/` directory if it does not exist.

5.3 IF the filesystem write fails, THE orchestrator SHALL exit with a non-zero error code and display an error message.

### REQ-6: Confirmation to User

**User Story:** As a user, I want to receive confirmation when a decision is stored, so that I know the information has been captured.

#### Acceptance Criteria

6.1 WHEN a decision is successfully persisted via any tier, THE skill SHALL display a confirmation message to the user indicating the domain where the rule was stored.

6.2 THE confirmation message SHALL include the path or service used for persistence.
