# Michael Nygard — Documenting Architecture Decisions

- Original: https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions
- Author: Michael Nygard; published 2011-11-15
- Accessed: 2026-10-03 (public article HTML)
- This is a paraphrased research note, **not a copy of the article**.

## Guidance

Large architecture documents are hard to maintain or read; small records retain the reasons behind choices so newcomers need not accept or reverse them blindly. Keep one significant, project-specific choice per short record, in version control and sequentially numbered. Nygard's example of significance includes structure, quality attributes, dependencies, interfaces, and construction techniques.

His template includes a short title; **context** describing technological, political, social, and local forces in factual, value-neutral terms; **decision** stated in full, active sentences; **status** distinguishing proposed from accepted (and later deprecated or superseded); and **consequences** describing positive, negative, and neutral resulting conditions. He recommends roughly one or two pages and prose readable by a future developer rather than fragments disguised as bullets.

When reversing a decision, retain the old record and link it to the replacing record rather than deleting or repurposing it. Its history explains why the architecture evolved.

## Application to the skill

Use the minimal structure, unambiguous status, honest consequences, and linked supersession. Nygard does not require a separate alternatives section; the skill's brief alternatives guidance comes from Malan's appreciation of the earlier templates.
