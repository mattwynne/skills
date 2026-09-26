# Ruth Malan — Architecture Decisions

- Original: https://www.linkedin.com/pulse/architecture-decisions-ruth-malan
- Author: Ruth Malan
- Accessed: 2026-10-03 (public article HTML)
- This is a paraphrased research note, **not a copy of the article**. Follow the link for Malan's full argument and examples.

## Ideas relevant to ADRs

Malan treats architecture as the significant decisions shaping a system, citing Grady Booch's cost-of-change framing. Decisions can be intentional or accidental; failing to decide is itself consequential. Decisions both limit and enable later choices.

She identifies Jeff Tyree and Art Akerman's and Olaf Zimmermann's decision templates as earlier work, and describes Michael Nygard's simpler template as a "just enough" Agile-era approach. A useful record captures the decision, outcome sought, forces weighed, and implications. She specifically values the earlier templates' attention to alternatives considered and rejected, without suggesting every record must adopt their full template.

The deeper architectural contribution is surfacing trade-offs: for a desired outcome, what forces matter, what downsides arise, and what negative consequences need mitigation? The record is not a replacement for that thinking. Her examples include distributed-system complexity accompanying microservice benefits, and organizational autonomy accompanying duplicate libraries.

## Application to the skill

Keep ADRs short, but do not omit material forces, downsides, or credible rejected alternatives when those explain the choice. Discuss the trade-offs before writing the record.

## Referenced writers

- Grady Booch — architecture as significant design decisions, significance measured by cost of change.
- Jeff Tyree and Art Akerman — earlier decision template: https://doi.org/10.1109/MS.2005.27
- Olaf Zimmermann — earlier decision-template work, including rejected alternatives.
- Michael Nygard — lightweight ADR format: https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions
