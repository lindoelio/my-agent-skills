# Implementation Tasks

## Overview

This implementation creates the Contextual Stewardship AgentSkill with three core components: the Skill Manifest, TOON Format Specification, and Orchestrator Script.

The implementation is organized into 4 phases:

1. **Foundation** - Create directory structure and skill scaffold
2. **Feature Delivery** - Implement all three skill components
3. **Acceptance Criteria Testing** - Verify requirement behavior
4. **Final Checkpoint** - Validate completeness and spec integrity

**Estimated Effort**: Small (1-2 sessions)

## Phase 1: Foundation

- [x] 1.1 Create skill directory structure
  - Create the `contextual-stewardship/` directory with `references/` and `scripts/` subdirectories.
  - _Implements: REQ-4_

## Phase 2: Feature Delivery

- [x] 2.1 Create Skill Manifest (SKILL.md)
  - Create `contextual-stewardship/SKILL.md` with YAML frontmatter (name, description) and markdown body containing behavior instructions.
  - Include extraction logic for three domains: `arquitetura`, `negocio`, `fluxo_trabalho`.
  - Include graceful degradation instructions: check MCP tools first, then execute orchestrator script.
  - Include user confirmation message requirements.
  - _Implements: DES-1, REQ-1.1, REQ-1.2, REQ-1.3, REQ-1.4, REQ-2.1, REQ-2.2, REQ-4.1, REQ-6.1, REQ-6.2_

- [x] 2.2 Create TOON Format Specification
  - Create `contextual-stewardship/references/TOON_SPEC.md` with TOON syntax documentation.
  - Document domain-block structure with array notation.
  - Include example showing `arquitetura`, `negocio`, and `fluxo_trabalho` domains.
  - _Implements: DES-2, REQ-3.1, REQ-3.2, REQ-3.3, REQ-4.2_

- [x] 2.3 Create Orchestrator Script
  - Create `contextual-stewardship/scripts/orchestrator.js` as a Node.js script.
  - Implement command-line argument parsing for TOON content.
  - Implement filesystem fallback: create `~/.agents/` directory if needed, append to `stewardship.toon`.
  - Implement error handling with non-zero exit code and error message display.
  - _Implements: DES-3, REQ-4.3, REQ-5.1, REQ-5.2, REQ-5.3_

## Phase 3: Acceptance Criteria Testing

- [x] 3.1 Test: SKILL.md frontmatter validation
  - Verify the skill manifest has valid YAML frontmatter with `name: contextual-stewardship` and valid `description`.
  - Test type: unit
  - _Implements: REQ-4.1_

- [x] 3.2 Test: TOON format specification structure
  - Verify TOON_SPEC.md contains domain-block examples for all three domains.
  - Test type: unit
  - _Implements: REQ-3.1, REQ-3.2_

- [x] 3.3 Test: orchestrator.js directory creation
  - Verify the script creates `~/.agents/` directory when it does not exist.
  - Test type: integration
  - _Implements: REQ-5.2_

- [x] 3.4 Test: orchestrator.js file append
  - Verify the script appends TOON content to `~/.agents/stewardship.toon` and confirms success.
  - Test type: integration
  - _Implements: REQ-5.1_

- [x] 3.5 Test: orchestrator.js error handling
  - Verify the script exits with non-zero code and displays error message on filesystem failure.
  - Test type: integration
  - _Implements: REQ-5.3_

## Phase 4: Final Checkpoint

- [x] 4.1 Verify all requirements are implemented
  - REQ-1: Confirm decision extraction logic covers all three domains.
  - REQ-2: Confirm graceful degradation from MCP to TOON file.
  - REQ-3: Confirm TOON format specification is complete.
  - REQ-4: Confirm all three files exist with correct paths.
  - REQ-5: Confirm orchestrator handles all specified error cases.
  - REQ-6: Confirm skill instructs user confirmation on persistence.
  - Run skills-ref validate on the skill directory and resolve any errors.
  - _Implements: All requirements_
