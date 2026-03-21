# Decision Framework

Detailed guidance for deciding when and how to use sequential thinking.

## Complexity Assessment Checklist

Before invoking sequential thinking, answer these questions:

1. **Is the solution path obvious?** If you can immediately see the steps, skip the tool.
2. **Are there multiple valid approaches?** Yes → consider using the tool to explore.
3. **Could my initial assumption be wrong?** Yes → sequential thinking helps catch errors.
4. **Will this require backtracking or revision?** Yes → structured reasoning prevents confusion.
5. **Is the problem scope unclear?** Yes → use the tool to break it down.

If 2+ answers suggest complexity, use sequential thinking.

## Thought Count Estimation

| Problem Type | Recommended `totalThoughts` |
|--------------|----------------------------|
| Simple debugging | 3-4 |
| Feature design | 4-6 |
| Architecture decision | 5-8 |
| Complex debugging | 6-10 |
| Open-ended analysis | Start at 5, extend as needed |

**Rules of thumb:**
- Start lower, extend with `needsMoreThoughts: true`
- If you exceed initial estimate, set `totalThoughts` to match `thoughtNumber`
- Never go below 3 thoughts — if that's enough, you probably don't need the tool

## Timeout Risk Indicators

Watch for these signs that you're approaching context/timeout limits:

- Thought count exceeds 10
- Thoughts are repeating information
- Progress has stalled (no new insights in 2+ thoughts)
- The `thoughtHistoryLength` in responses is growing rapidly

**Recovery strategies:**
- Summarize findings in a final thought with `nextThoughtNeeded: false`
- If more work needed, start fresh sequence with summary as thought 1

## Branching Strategy

Use branching when:

- You hit a dead end and want to explore an alternative
- Multiple approaches seem equally valid
- You want to compare tradeoffs systematically

**Branch naming:** Use descriptive IDs like `"approach-async"`, `"hypothesis-memory-leak"`, `"alt-database-schema"`

**Pattern:**

```json
// Main line
{ "thought": "Approach A: use Redis caching", "thoughtNumber": 3, "totalThoughts": 6, "nextThoughtNeeded": true }

// Branch from thought 3
{ "thought": "Approach B: use in-memory cache with TTL", "thoughtNumber": 4, "totalThoughts": 6, "nextThoughtNeeded": true, "branchFromThought": 3, "branchId": "in-memory-approach" }
```

## Revision Pattern

Use revision when:

- New information contradicts earlier conclusions
- You realize an assumption was incorrect
- A later step reveals an error in earlier reasoning

**Always specify `revisesThought`** to maintain clear provenance.

**Pattern:**

```json
// Original thought
{ "thought": "The bug is in the authentication layer", "thoughtNumber": 2, "totalThoughts": 5, "nextThoughtNeeded": true }

// Later, you discover new info
{ "thought": "Actually, auth is fine. The issue is in the session middleware — thought 2 was incorrect", "thoughtNumber": 4, "totalThoughts": 5, "nextThoughtNeeded": true, "isRevision": true, "revisesThought": 2 }
```

## Decision Tree

```
START
  │
  ▼
Is this a single-step task? ──────────────────────► SKIP
  │
  No
  ▼
Is the solution immediately obvious? ─────────────► SKIP
  │
  No
  ▼
Are there multiple valid approaches? ─────────────► USE
  │
  No
  ▼
Could assumptions be wrong? ──────────────────────► USE
  │
  No
  ▼
Is the problem scope unclear? ────────────────────► USE
  │
  No
  ▼
Did initial attempt fail? ────────────────────────► USE
  │
  No
  ▼
SKIP (use direct response)
```

## Anti-Patterns

**Overthinking simple problems:**
- ❌ Using 5 thoughts to decide between `const` and `let`
- ✅ Direct answer based on mutability requirement

**Underthinking complex problems:**
- ❌ Jumping to conclusion without exploring alternatives
- ✅ Using sequential thinking to systematically evaluate

**Infinite loops:**
- ❌ Extending `totalThoughts` indefinitely without progress
- ✅ Set `nextThoughtNeeded: false` when diminishing returns hit

**Thought bloating:**
- ❌ Each thought is a paragraph of text
- ✅ Each thought is one focused insight (1-3 sentences)