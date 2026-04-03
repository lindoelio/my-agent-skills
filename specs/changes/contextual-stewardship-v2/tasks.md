# Implementation Tasks

## Overview

This implementation extends the Contextual Stewardship AgentSkill to support bidirectional read/write operations with a Pre-flight Check pattern. The work is organized into 4 phases.

1. **Foundation** - Update SKILL.md with Pre-flight Check instructions
2. **Feature Delivery** - Refactor orchestrator.js to support retrieve and save commands
3. **Acceptance Criteria Testing** - Verify all requirement behaviors
4. **Final Checkpoint** - Validate spec completeness

**Estimated Effort**: Small (2-3 sessions)

## Phase 1: Foundation

- [x] 1.1 Update SKILL.md description and triggers
  - Update the skill description to include retrieval trigger conditions: "before implementing a feature, writing code, planning architecture, or making technical decisions."
  - Add Pre-flight Check instruction to invoke retrieval mechanism before technical actions.
  - _Implements: DES-1, REQ-5.1, REQ-5.2_

- [x] 1.2 Add retrieval workflow section to SKILL.md
  - Add a new "Retrieval Strategy (Pre-flight Check)" section describing the two-tier retrieval chain.
  - Include Tier 1 (MCP Context) and Tier 2 (orchestrator retrieve) instructions.
  - Clarify that save operations remain unchanged.
  - _Implements: DES-1, DES-3, REQ-3.1, REQ-3.2, REQ-3.3, REQ-4.1, REQ-4.2, REQ-4.3, REQ-5.3_

- [x] 1.3 Add confirmation message format for retrieval
  - Add confirmation message examples showing retrieved context display and mechanism used.
  - _Implements: DES-1, REQ-1.3_

## Phase 2: Feature Delivery

- [x] 2.1 Refactor orchestrator.js command detection
  - Add logic to detect if first argument starts with "retrieve " (with trailing space).
  - Route to search mode if detected, otherwise proceed to save mode.
  - _Implements: DES-2, REQ-2.1, REQ-2.3_

- [x] 2.2 Implement retrieve search mode
  - Parse the query string after "retrieve " prefix.
  - Read the stewardship.toon file from ~/.agents/.
  - Search for entries matching the query domain or keywords.
  - _Implements: DES-2, REQ-2.1_

- [x] 2.3 Implement domain-grouped output formatting
  - Format matched entries grouped by domain (arquitetura, negocio, fluxo_trabalho).
  - Return "No matching entries found" if no matches.
  - Ensure output is concise and human-readable.
  - _Implements: DES-2, REQ-6.1, REQ-6.2, REQ-6.3_

- [x] 2.4 Preserve save mode behavior
  - Verify existing save behavior (appending TOON content) remains unchanged when argument is not "retrieve " prefix.
  - _Implements: DES-2, REQ-2.2_

## Phase 3: Acceptance Criteria Testing

- [x] 3.1 Test: SKILL.md triggers Pre-flight Check before technical tasks
  - Verify the skill description includes retrieval trigger conditions for implement, write code, plan architecture, make technical decision.
  - Test type: integration
  - _Implements: REQ-5.1_

- [x] 3.2 Test: Orchestrator retrieve command searches TOON file
  - Execute `node orchestrator.js retrieve arquitetura` and verify it searches the TOON file.
  - Test type: integration
  - _Implements: REQ-2.1, REQ-2.3_

- [x] 3.3 Test: Orchestrator save command appends TOON content
  - Execute `node orchestrator.js "<toon_content>"` and verify content is appended.
  - Test type: integration
  - _Implements: REQ-2.2_

- [x] 3.4 Test: Retrieval output is grouped by domain
  - Add test entries to TOON file, execute retrieve, verify output is grouped by domain.
  - Test type: integration
  - _Implements: REQ-6.1_

- [x] 3.5 Test: Retrieval output indicates no matches when empty
  - Execute retrieve with non-existent query, verify "No matching entries found" message.
  - Test type: integration
  - _Implements: REQ-6.2_

- [x] 3.6 Test: Retrieval output is human-readable format
  - Verify formatted output is not raw TOON syntax.
  - Test type: integration
  - _Implements: REQ-6.3_

- [x] 3.7 Test: Save confirmation indicates mechanism used
  - Verify save operation confirmation includes persistence mechanism.
  - Test type: integration
  - _Implements: REQ-4.3_

## Phase 4: Final Checkpoint

- [x] 4.1 Verify all acceptance criteria
  - REQ-1: Confirm Pre-flight Check retrieval pattern is documented and actionable.
  - REQ-2: Confirm orchestrator supports both retrieve and save commands.
  - REQ-3: Confirm graceful degradation for retrieval is documented.
  - REQ-4: Confirm graceful degradation for persistence is documented.
  - REQ-5: Confirm SKILL.md triggers cover all required scenarios.
  - REQ-6: Confirm retrieval output meets format requirements.
  - Run relevant integration tests and resolve any gaps.
  - _Implements: All requirements_

- [x] 4.2 Validate complete spec structure
  - Verify requirements.md, design.md, and tasks.md are consistent.
  - Confirm all DES-* elements are implemented.
  - Confirm all REQ-* acceptance criteria are covered by test tasks.
  - _Implements: All requirements_
