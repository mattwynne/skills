---
name: documentation-cleanup
description: Clean up cluttered repository documentation, especially indexes, running histories, repeated caveats and duplicated status or evidence. Use for document structure and information placement, not ordinary line editing or code simplification.
---

# Documentation cleanup

Make each document's purpose obvious and keep only what serves it. The goal is useful documentation, not the fewest words.

## Give each document one job

Read the repository's documentation conventions and the requested documents before editing. Follow links when needed to understand where information belongs.

| Document | Owns |
| --- | --- |
| Index | A simple table or list of links, plus maintenance instructions |
| Problem note | An unresolved need, observations, constraints and resolution checks |
| Iteration record | Agreed scope, acceptance and delivery evidence |
| ADR | A lasting decision, its context and consequences |
| Operating guide | Current procedures |
| Dated note | Historical observations or investigation |
| Task tracker | Execution to-dos and live state |

Link rather than repeat. Do not turn an index into a roadmap, a problem into a delivery diary, or a plan into a second task tracker. Follow repository-specific conventions where they differ from this table.

## Remove clutter without changing meaning

- Cut running totals, accumulated status narratives, repeated caveats, stale instructions, duplicated detail and defensive prose that adds no useful constraint.
- Keep summaries short. Put detailed facts in their owning record and link to it.
- Delete redundant information. Move useful, unique information to an appropriate record before removing it from the wrong place.
- Do not create a new archive merely to preserve every deleted sentence. Git retains edit history; durable decisions and evidence still need an accessible home.
- Preserve meaningful constraints, unresolved risks, acceptance checks and evidence. Keep distinctions such as planned versus delivered, manual versus automated, and deferred versus solved.
- Do not change scope, assignments, approval, problem identity or status as incidental cleanup. An old statement is not necessarily false, and completed implementation does not prove acceptance.
- If conflicting records require a substantive decision, flag the conflict rather than silently choosing one. Continue with unambiguous cleanup.

Work within the requested document set; inspect linked material as needed, but do not expand into a repository-wide rewrite without authorization.

## Explain the system, not the diff

Look for **change-relative prose**: descriptions of how things used to work, often followed by “no longer”, “now”, “previously”, “instead of” or “unchanged”. These comparisons may have helped the agent explain its edit at the time, but leave future readers learning an obsolete system before understanding the current one.

For example:

> Our startup scripts no longer run npm installation, TypeScript compilation or `bb plugin build`.

Prefer the current behavior:

> Dependencies and application artifacts are built into the image. BB compiles local plugins when loading them, using the compiler included in the image.

Ask: does knowing the former behavior help the reader do something today? If not, remove the comparison and state the current behavior directly—or delete the sentence if that behavior is already explained nearby. Avoid replacing an obsolete-history paragraph with another redundant summary.

Keep historical comparisons when they support a current migration, compatibility requirement or decision rationale. Preserve relevant history in ADRs, dated notes and delivery evidence; do not mechanically strip these words or erase historical records. Distinguish a useful warning about a still-possible mistake from commentary about an implementation that no longer exists.

## Check and hand back

Review the diff for lost facts or stronger claims. Check changed links and anchors, table entries, identifiers and statuses. Follow the repository's lifecycle rules when removing records and repair inbound references.

Report briefly which documents were simplified, what checks passed and any decisions still needed. Do not add a cleanup diary to the documents themselves.
