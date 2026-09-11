---
name: writing-adrs
description: Use when creating or editing Architecture Decision Records - guides thinking through decisions with stakeholders before documenting the outcome
---

# Writing ADRs

Use this skill when creating or editing Architecture Decision
Records.

## What ADRs are

Together, ADRs form a log of the trade-offs we've made that
constrain future implementation. Each ADR captures a single
decision: the forces at play, the path we chose, and what that
choice makes easier or harder going forward.

An ADR is not a feature log, a changelog, or a TODO list.

## The ADR writing process

Writing an ADR is a thinking exercise, not just documentation.
Your job is to help the human think clearly about the decision
and its implications — challenge them, surface concerns they
may not have considered, and help them articulate the trade-offs.

### 1. Understand the landscape

Read `docs/adrs/README.md` to scan the existing decisions.
Read in detail any ADRs that relate to the current decision —
does this amend, supersede, or build on something already
recorded?

If the project doesn't have `docs/adrs/README.md` yet, help
the human set it up. Every project should index its ADRs there.

### 2. Think through the decision with the human

Before writing anything, have a conversation:

- What problem does this solve? What forces are at play?
- What alternatives were considered? Why were they rejected?
- What concerns do you have about this approach?
- What does this make harder? What new constraints does it
  introduce?

Ask one question at a time. Don't rush to write — the
conversation *is* the valuable part. The document captures
the outcome.

Push back where appropriate. If the human hasn't considered
an alternative, suggest one. If the consequences seem
one-sided, ask what the costs are. If the decision seems
larger than one ADR, help decompose it.

### 3. Write the ADR

Use [adrgen](https://github.com/asiermarques/adrgen) to
manage ADR files:

1. Check `adrgen list` for the next available number.
2. Run `adrgen create "Title"` to generate the file.
3. Write the content (see principles below).
4. Update `docs/adrs/README.md` to add the new entry.

If adrgen is not installed, create the file manually following
the same numbered naming convention (e.g.
`docs/adrs/0012-use-event-sourcing.md`).

### 4. Review the draft

Run two subagent reviews sequentially. Both should read
the draft ADR *and* the existing ADRs in `docs/adrs/`.

**First — coherence & references reviewer:**

- Does the draft duplicate or contradict an existing ADR
  without acknowledging it?
- Are there existing ADRs that should be cross-referenced
  (amends, supersedes, builds on)?
- Are relevant context links included (PRs, tickets,
  design docs)?

Apply the coherence reviewer's fixes to the draft before
continuing.

**Second — adversarial reviewer** (reads the updated draft):

- Are the consequences one-sided? What costs are missing?
- Is implementation detail leaking into the decision?
- Are rejected alternatives given a fair hearing, or
  straw-manned?
- Does the context actually connect the forces to the
  decision?
- Would a reader unfamiliar with the project understand
  *why*?
- Is anything vague enough to mean different things to
  different readers?

Share the adversarial reviewer's findings with the human
and revise the ADR together before finalising.

## Writing principles

*"Perfection is achieved, not when there is nothing more to
add, but when there is nothing left to take away."*
— Antoine de Saint-Exupéry

A good ADR is well thought out, concise, and honest about
trade-offs. Every sentence should earn its place. If a detail
doesn't help a future reader understand the *why* or the
*trade-offs*, cut it.

### Intent, not implementation

The code is the source of truth for how things work. An ADR
records *why* we chose this path and *what constraints* it
creates.

Describe capabilities and constraints, not recipe names,
CLI flags, or file paths. If someone needs the exact command,
they'll read the code or the README.

**Bad (implementation-heavy):**

> - **`just coder terminal-create`** — create a workspace
>   non-interactively, with all template parameters specified
>   in `coder/parameters.yaml`. Supports `--force` to delete
>   and recreate.

**Good (intent-level):**

> - creating an imogen-terminal VM

### *Why*, not just *what*

Context should connect facts to the decision. Don't just state
what exists — explain the forces that led here.

**Bad:**

> The `gcp-linux-vm` template creates VMs suitable for running
> integration tests.

**Good:**

> The `gcp-linux-vm` template creates VMs that represent a
> delivery engineer's typical working environment, and so makes
> them suitable for running integration tests.

### Consequences are trade-offs

Split consequences into two lists: what becomes easier and what
becomes harder. Be honest about both sides.

**Example:**

> **Easier:**
> - Test-generated files on the host are owned by the
>   developer's user — no `sudo` needed for cleanup.
>
> **Harder / things to be aware of:**
> - The entrypoint requires the container to start as `root`
>   so it can rewrite `/etc/passwd` before dropping privileges.

Don't use consequences as a feature summary or a backlog.

## Structure

- **Status** — `accepted`, `proposed`, or a relationship
  (`amends`, `supersedes`, `prerequisite for`)
- **Context** — the situation and forces at play
- **Decision** — what we are doing about it
- **Consequences** — what becomes easier, what becomes harder
