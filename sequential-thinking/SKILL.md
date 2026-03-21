---
name: sequential-thinking
description: Use this skill when facing complex problems requiring multi-step reasoning, architectural decisions, debugging with unclear root causes, or tasks where the problem scope is uncertain. Invoke even if the user doesn't explicitly mention "reasoning" or "thinking through" — triggers on phrases like "figure out why", "analyze this", "what's the best approach", or when initial attempts fail.
license: MIT
allowed-tools: mcp__sequentialthinking__sequentialthinking
---

# Sequential Thinking

Structured reasoning for complex problems. Break down ambiguous tasks, explore alternatives, and revise conclusions as understanding deepens.

## Quick Start

```
mcp__sequentialthinking__sequentialthinking({
  thought: "First, I need to understand what's causing the intermittent failure...",
  thoughtNumber: 1,
  totalThoughts: 5,
  nextThoughtNeeded: true
})
```

## When to Use

| Trigger Pattern | Example |
|-----------------|---------|
| Problem scope unclear | "Something's wrong with the API but I'm not sure what" |
| Multi-step reasoning required | "Help me design a caching strategy" |
| Root cause unknown | "This bug only happens under load" |
| Multiple valid approaches | "Should I use PostgreSQL or MongoDB for this?" |
| Initial attempt failed | "I tried fixing it but it's still broken" |
| Architectural decisions | "How should I structure the microservices?" |
| Complex debugging | "The race condition is hard to reproduce" |

## When to SKIP

Do NOT use sequential thinking for:

| Skip Pattern | Why |
|--------------|-----|
| Simple lookups | "What's the capital of France?" |
| Known solutions | "Add error handling to this function" |
| Formatting tasks | "Convert this JSON to YAML" |
| Single-step edits | "Rename this variable" |
| Factual queries | "What does `git rebase` do?" |
| Trivial calculations | "Sum these numbers" |
| Straightforward implementations | "Create a login form with these fields" |

## Timeout Prevention

**1. Start conservative:** Estimate `totalThoughts` at 3-5 for most problems. Extend with `needsMoreThoughts: true` if needed.

**2. Chunk reasoning:** If approaching 10+ thoughts, summarize findings and restart the sequence.

**3. Dynamic adjustment:** Set `nextThoughtNeeded: false` early if the answer becomes clear.

**4. Avoid overthinking:** If 3 consecutive thoughts don't add value, conclude.

## Core Patterns

### Linear Progression

Standard step-by-step reasoning:

```json
{ "thought": "Analyze the error stack trace...", "thoughtNumber": 1, "totalThoughts": 4, "nextThoughtNeeded": true }
{ "thought": "Identify the failing component...", "thoughtNumber": 2, "totalThoughts": 4, "nextThoughtNeeded": true }
{ "thought": "Trace the data flow...", "thoughtNumber": 3, "totalThoughts": 4, "nextThoughtNeeded": true }
{ "thought": "Root cause is X, fix is Y", "thoughtNumber": 4, "totalThoughts": 4, "nextThoughtNeeded": false }
```

### Revision

Correct previous reasoning:

```json
{ "thought": "Wait, my assumption in thought 2 was wrong...", "thoughtNumber": 3, "totalThoughts": 5, "nextThoughtNeeded": true, "isRevision": true, "revisesThought": 2 }
```

### Branching

Explore alternatives:

```json
{ "thought": "Alternative approach: what if we use async/await instead?", "thoughtNumber": 4, "totalThoughts": 6, "nextThoughtNeeded": true, "branchFromThought": 3, "branchId": "async-approach" }
```

## Examples

### Example: Complex Debugging (USE tool)

User: "My API works locally but fails in production sporadically"

```
Thought 1: "List differences between local and production environments..."
Thought 2: "Check for race conditions in shared state..."
Thought 3: "Investigate timeout configurations..."
Thought 4: "Production has different load balancer settings causing session affinity issues"
```

### Example: Simple Task (SKIP tool)

User: "Add a README file to this project"

Direct response. No sequential thinking needed — straightforward single-step task.

### Example: Format Conversion (SKIP tool)

User: "Convert this CSV to JSON"

Direct response. Use appropriate tools, no complex reasoning required.

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `thought` | Yes | Current reasoning step |
| `thoughtNumber` | Yes | Current step number (1-indexed) |
| `totalThoughts` | Yes | Estimated total steps needed |
| `nextThoughtNeeded` | Yes | `true` if more steps needed |
| `isRevision` | No | Mark as revision of previous thought |
| `revisesThought` | No | Which thought number is being revised |
| `branchFromThought` | No | Branch point thought number |
| `branchId` | No | Identifier for the branch |
| `needsMoreThoughts` | No | Request more thoughts than estimated |

## Reference

For detailed decision frameworks and advanced patterns, see [references/decision-framework.md](references/decision-framework.md).