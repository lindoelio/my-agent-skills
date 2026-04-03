# Requirements

## Overview

The Contextual Stewardship AgentSkill must evolve from a write-only memory system to a bidirectional read/write system. The skill shall instruct agents to retrieve contextual memory BEFORE proposing architectures, writing code, or making technical decisions. This creates a "Pre-flight Check" pattern where established patterns and past decisions guide every technical action.

The system maintains the existing graceful degradation chain (MCP Context → TOON local file) for both read and write operations, ensuring reliability regardless of available infrastructure.

## Glossary

| Term | Definition |
|------|------------|
| Pre-flight Check | A retrieval operation performed by the agent before initiating any technical task to ensure alignment with established project patterns |
| TOON | Token-Oriented Object Notation - a flat, domain-grouped format for persisting contextual memories |
| Graceful Degradation | A fallback chain where Tier 1 (MCP Context) is attempted first, falling back to Tier 2 (local TOON file) if unavailable |

## Assumptions

- The skill is invoked in an AI agent context with access to a Bash tool for script execution
- The TOON file format remains unchanged (domain: `arquitetura`, `negocio`, `fluxo_trabalho`)
- The existing skill files (`SKILL.md`, `scripts/orchestrator.js`) are in `contextual-stewardship/` directory
- Agents understand the trigger phrases "implement", "write code", "plan architecture", "make technical decision"

## Requirements

### REQ-1: Pre-flight Context Retrieval

**User Story:** As an AI agent, I want to retrieve project contextual memory BEFORE taking technical actions, so that I follow established patterns and respect past decisions.

#### Acceptance Criteria

1.1 WHEN an agent initiates a technical task (implement feature, write code, plan architecture, or make technical decision), THEN the agent SHALL invoke the skill to retrieve contextual memory first.

1.2 THE agent SHALL search the retrieved context for relevant rules in the `arquitetura`, `negocio`, and `fluxo_trabalho` domains before proceeding with the technical task.

1.3 THE agent SHALL display a summary of relevant matched rules to the user before taking action.

### REQ-2: Bidirectional Command Support

**User Story:** As a skill implementer, I want the orchestrator to support distinct `retrieve` and `save` commands, so that the skill can perform both context lookup and memory persistence.

#### Acceptance Criteria

2.1 WHEN the orchestrator receives `retrieve <query>` as the first argument, THEN it SHALL search the TOON file for entries matching the query domain or keywords.

2.2 WHEN the orchestrator receives a TOON-formatted string (without `retrieve` prefix), THEN it SHALL append the content to the TOON file in save mode (existing behavior).

2.3 THE orchestrator SHALL support command syntax: `node orchestrator.js retrieve <query>` for retrieval and `node orchestrator.js "<toon_content>"` for save.

### REQ-3: Graceful Degradation for Retrieval

**User Story:** As an agent, I want context retrieval to gracefully degrade when MCP Context is unavailable, so that I can always access project memory via the local TOON file.

#### Acceptance Criteria

3.1 WHILE MCP Context tool is available for memory retrieval, THE agent SHALL use it to retrieve context first.

3.2 WHEN MCP Context retrieval is unavailable, THE agent SHALL fall back to the orchestrator `retrieve` command to search the local TOON file.

3.3 THE agent SHALL indicate which retrieval mechanism was used in the context summary.

### REQ-4: Graceful Degradation for Persistence

**User Story:** As an agent, I want memory persistence to gracefully degrade when MCP Context is unavailable, so that decisions are always preserved to local storage.

#### Acceptance Criteria

4.1 WHILE MCP Context tool is available for memory storage, THE agent SHALL use it to save new decisions first.

4.2 WHEN MCP Context storage is unavailable, THE agent SHALL fall back to the orchestrator save mode to append to the local TOON file.

4.3 THE agent SHALL confirm which persistence mechanism was used after saving.

### REQ-5: Skill Trigger Update

**User Story:** As a skill author, I want the skill description to explicitly instruct agents to retrieve context BEFORE acting, so that the Pre-flight Check pattern is consistently triggered.

#### Acceptance Criteria

5.1 THE skill description SHALL include trigger conditions for retrieval: "before implementing a feature, writing code, planning architecture, or making technical decisions."

5.2 THE skill SHALL provide explicit instruction to invoke the retrieval mechanism before any technical action.

5.3 THE skill description SHALL clarify that save operations remain unchanged for persistence during conversation.

### REQ-6: Retrieval Output Format

**User Story:** As an agent, I want retrieved context formatted clearly for quick review, so that I can efficiently apply matched rules to my technical task.

#### Acceptance Criteria

6.1 THE retrieval output SHALL display matched entries grouped by domain (`arquitetura`, `negocio`, `fluxo_trabalho`).

6.2 THE retrieval output SHALL indicate when no matching entries are found.

6.3 THE retrieval output SHALL be concise and human-readable, not raw TOON format.
