---
name: exploratory-testing
description: Use when a feature feels under-tested, after implementing new functionality, or before a release to discover edge cases, UX issues, and bugs through hands-on exploration
---

# Exploratory Testing

## Overview

**Exploratory testing discovers what automated tests miss.** The agent acts as a curious, methodical user: running the product in a safe environment, observing behaviour, trying edge cases, and logging findings.

Each session is guided by a charter that focuses exploration on a specific area with specific heuristics.

## When to Use

- After implementing a new feature or fixing a bug
- Before a release, to shake out edge cases
- When behaviour feels under-tested
- When you want to stress-test error handling, output formatting, state transitions, or UX
- Periodically, to discover regressions or papercuts

**Don't use when:**

- You need deterministic, repeatable test coverage (write automated tests instead)
- The area has no working implementation yet

## Phase 1: Charter

### Agree on a Target

The user provides, or the agent suggests, a target area to explore. Good targets are specific commands, workflows, screens, APIs, or quality attributes:

- "the add item command"
- "the checkout flow"
- "error messages when uploads fail"
- "output formatting across JSON and plain-text modes"
- "a full workflow: create, edit, complete, archive"

### Select Heuristics

Pick 2-4 heuristics from the menu below that suit the target:

| Heuristic | Application |
|-----------|-------------|
| **CRUD** | Create, read, update, delete through a full lifecycle |
| **Zero, One, Many** | Empty state, single item, many items, deep nesting |
| **Boundary Values** | Long names, special characters, spaces, empty strings, unicode, maximum sizes |
| **Never and Always** | Invariants that should never or always hold |
| **Follow the Data** | Create -> list -> modify -> list -> verify consistency |
| **Some, None, All** | Filters or selections with matching, non-matching, and all items |
| **Starve** | Missing files, missing config, no network, no permissions, unavailable dependencies |
| **Interrupt** | Broken pipes, partial input, cancellation, refresh, retry, Ctrl-C |
| **Configuration Tour** | Options, flags, environment variables, preferences, feature toggles |
| **Claims Tour** | Does help text, documentation, or UI copy match actual behaviour? |
| **Sequence Variation** | Unusual command or workflow orders |
| **User Tour** | Common real-world workflows end-to-end |

### Write the Charter

Format the charter using Elisabeth Hendrickson's template:

> **Explore** [target area]  
> **With** [selected heuristics]  
> **To Discover** [risks or information we seek]

Example:

> **Explore** the add item command  
> **With** Boundary Values, Zero/One/Many, Claims Tour  
> **To Discover** how it handles edge-case input and whether `--help` accurately describes its behaviour

### Approval Gate

Present the charter to the user. **Do not proceed until the user confirms the charter.** The user may adjust the target, heuristics, or risk focus.

## Phase 2: Exploration

### Set Up a Safe Environment

Create an isolated environment so exploration never damages real user or production data. Depending on the project, this might be:

- a temporary directory;
- a test database;
- a local sandbox account;
- a disposable fixture file;
- a development server with fake credentials;
- a branch or worktree created for exploration.

State clearly how the sandbox is isolated before you begin.

### Seed the Environment

Before exploring, create enough data to work with. Adapt seeding to the charter: if exploring hierarchy, create nested data; if exploring empty state, start with no data; if exploring limits, create boundary-sized inputs.

### Explore Systematically

Work through each chartered heuristic. For each probe:

1. **State what you're testing**: the heuristic and specific probe.
2. **Run the command, API call, UI action, or workflow step.**
3. **Record the result** in your session log.

Keep a running session log in this format:

```markdown
### [Heuristic Name]

**Probe:** [what you're trying]
**Action:** [command, API call, or UI steps]
**Expected:** [what you thought would happen]
**Actual:** [what actually happened]
**Verdict:** OK | BUG | UX-ISSUE | INCONSISTENCY | UNEXPECTED | QUESTION
**Notes:** [any additional observations]
```

### Exploration Guidelines

- Stay within the charter scope. If you discover something interesting outside scope, note it for a future session.
- Vary inputs. Don't just test happy paths.
- Pay attention to output, copy, layout, state changes, persistence, and recovery.
- Check exit codes or HTTP status codes when relevant.
- Try composition where relevant: piping CLI output, refreshing pages, retrying calls, or switching formats.
- Time-box yourself. 15-30 minutes of exploration per charter is usually enough.

## Phase 3: Report

### Present Findings

After exploration, present a structured report to the user.

#### Summary

One-line summary: how many probes, how many findings, and the overall impression.

#### Findings by Category

Group findings into these categories, skipping empty ones:

| Category | Description |
|----------|-------------|
| **Bugs** | Incorrect behaviour, crashes, wrong state, wrong exit/status codes |
| **UX Issues** | Confusing output, unclear errors, surprising defaults |
| **Inconsistencies** | Behaviour differs between similar commands, screens, or cases |
| **Missing Error Handling** | No error where one is expected, or unhelpful messages |
| **Unexpected Behaviour** | Works, but not how a user would expect |
| **Worked Well** | Things that behaved exactly right or had good UX |

For each finding, include:

- the action that triggered it;
- what happened vs what was expected;
- severity estimate: low / medium / high;
- evidence: output, screenshot description, logs, or file paths when available.

#### Suggested Follow-Ups

Concrete next steps:

- bugs or improvement tasks to create;
- automated tests to write for discovered edge cases;
- documentation to update if claims are misleading;
- areas worth a dedicated exploratory testing session.

### Clean Up

Remove temporary data, shut down test services, or tell the user what remains and why.

## Quick Reference

| Phase | What Happens | Gate |
|-------|-------------|------|
| Charter | Agree target, select heuristics, write charter | User approves charter |
| Exploration | Sandbox setup, systematic probing, session log | None — explore autonomously |
| Report | Categorised findings, follow-ups, cleanup | User reviews findings |

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Exploring without a charter | Always agree on target and heuristics first |
| Only testing happy paths | Heuristics exist to push beyond the obvious |
| Logging only failures | Record successes too — they confirm expected behaviour |
| Exploring everything at once | Pick 2-4 heuristics per session, stay focused |
| Skipping status checks | Check exit codes, HTTP status, persisted state, or logs when relevant |
| Not seeding enough data | Adapt seed data to what the charter needs |

## Sources

- Elisabeth Hendrickson: *Explore It!*
- James Bach: Session-Based Test Management
- Michael Bolton: "Testing vs. Checking"
