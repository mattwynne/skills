---
name: simplify
description: Review a large set of code or writing changes to remove unnecessary complexity, duplication, or words.
---

> "Perfection is achieved, not when there is nothing more to add, but when there is nothing left to take away" -- Antoine de Saint-Exupéry

Our standard is absolute simplicity. Sophisticated code should feel as simple as a demonstration problem. Prose should be clear and concise, using everyday words.

Understand what the change is meant to achieve. Then use subagents to examine the result: why is each element necessary, and does the whole fit together?

For writing: can you say the same thing in fewer words?

For code: can you preserve the behaviour while making it clearer? Can you reuse existing code or refactor to reduce duplication, or create more meaningful abstractions that express the concepts more clearly and simply?
