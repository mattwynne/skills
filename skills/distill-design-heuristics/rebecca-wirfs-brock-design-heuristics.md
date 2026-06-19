# Rebecca Wirfs-Brock on Design Heuristics: Capturing, Distilling, and Communicating Practical Design Wisdom

## Purpose

This document summarizes Rebecca Wirfs-Brock’s work on software design heuristics and turns it into a practical guide for teams that want to capture, distill, and communicate their own design judgment.

Wirfs-Brock is best known for Responsibility-Driven Design and object design, but her later work on heuristics focuses on an adjacent problem: how experienced designers actually decide what to do when no rule, pattern, or process can guarantee the right answer.

## Core idea

A design heuristic is a fallible, context-sensitive aid to making progress. Wirfs-Brock draws heavily on Billy Vaughn Koen’s definition of a heuristic as anything that provides “a plausible aid or direction in the solution of a problem” but is ultimately unjustified, incapable of complete justification, and potentially fallible.

The important implications are:

- Heuristics are not rules.
- They are not universally true.
- They help designers move under uncertainty.
- They compete with other heuristics.
- Their usefulness depends on context, values, experience, constraints, and consequences.
- Expert judgment is partly the ability to know when to apply, adapt, ignore, or replace a heuristic.

## Types of heuristics

Wirfs-Brock describes several useful categories.

### 1. Action heuristics

These are things we do to solve an immediate problem.

Examples:

- Use TDD to develop and test deterministic functionality.
- Generate separate business events when downstream processes react differently.
- Build a system in a clean environment to discover missing dependencies.

Design patterns are a well-known, more formalized kind of action heuristic.

### 2. Meta-heuristics

These guide the use of other heuristics.

Examples:

- If the current tactic is not buying useful information, stop doing it and try another.
- Always give yourself a chance to retreat.
- Use feedback to stabilize your design.

### 3. Value heuristics

These express values that make some actions seem appropriate.

Examples:

- Testing should be integral to design and coding.
- Understandable code is worth effort.
- Frequent feedback reduces risk.

Value heuristics matter because teams often argue about practices when the real disagreement is about values.

## Best practices for capturing heuristics

### Capture them from real work, not only from opinions

Wirfs-Brock emphasizes “heuristics hunting”: observing design, programming, modeling, testing, and decision-making as it happens. People often cannot accurately report what they actually do. They may describe an idealized practice, a remembered rule, or a team norm, while their real behavior is more nuanced.

Capture heuristics from:

- Design sessions
- Pairing or mobbing sessions
- Architecture reviews
- Incident reviews
- Refactoring work
- Testing strategy discussions
- Code review comments
- Stories about past failures or successes

Record both what people say and what they actually do.

### Use conversations and stories

Open-ended conversations are especially effective. Ask people to tell stories about a difficult design choice, then listen for the practical judgment embedded in the story.

Good prompts:

- What did you try first?
- What made that seem like the right next move?
- When would that advice fail?
- What did you avoid doing?
- What did you learn only after living with the design?
- What signs tell you to switch approaches?
- What tradeoff were you making?

### Write by hand when possible

Wirfs-Brock argues for physically writing heuristics, especially early in the capture process. Writing helps memory; longhand writing encourages processing rather than merely transcribing; written heuristics can then be shared and discussed.

### Capture context immediately

A heuristic without context turns into a slogan. Record:

- Situation: What problem were we solving?
- Context: What domain, system, team, constraints, and stage of work?
- Forces: What pressures, risks, and tradeoffs mattered?
- Trigger: What sign suggested this heuristic was relevant?
- Action: What did we do?
- Consequences: What happened? What improved? What got worse?
- Limits: When would we not use this?
- Competing heuristics: What else might have worked?

### Do not over-polish too early

Early captures should be fast and rough. The goal is to preserve the design thinking before it evaporates. Precision can come later.

## QHE cards: a lightweight capture format

Wirfs-Brock proposes QHE cards: Question, Heuristic, Example. They are inspired by CRC cards and are deliberately smaller than a full design pattern but richer than a sticky-note slogan.

### QHE template

**Question**
What design question does this heuristic help answer?

**Heuristic**
What practical guidance helps us make progress?

**Example**
What concrete example makes this memorable?

### Example

**Question**
How do we decide how many events to generate from a single business process?

**Heuristic**
If different downstream processes react differently, generate different events.

**Example**
A rental car return may generate both “car returned” and “mileage recorded.” Mileage can be recorded independently, so combining both meanings into one overloaded event muddies the design.

## Best practices for distilling heuristics

### Move from raw observation to useful formulation

A good distillation usually moves through these stages:

1. Raw note: “Alice split the event because billing and fleet maintenance used it differently.”
2. Candidate heuristic: “Split events when different consumers care about different things.”
3. Refined heuristic: “If different downstream processes react differently, generate different events.”
4. Contextualized heuristic: “In event-driven business systems, avoid overloading one event with several business meanings. Generate separate events when downstream processes react differently or need independent lifecycles.”

### Preserve nuance

Wirfs-Brock warns that expert heuristics often sound like: “Do this when..., unless..., and then try..., until....” Do not flatten them into absolute rules.

A strong heuristic should include enough nuance to answer:

- When does this help?
- When does it fail?
- What assumptions does it rely on?
- What does it trade off?
- What should we watch after applying it?

### Record competing heuristics

Real design involves choosing among plausible options. If a heuristic has a rival, write both.

Example:

- “Write tests first to clarify behavior and create a safety net.”
- “When exploring short-lived code, do not let tests slow down learning.”

Both can be true. Judgment lies in knowing which context you are in.

### Separate action, value, and meta-heuristics

This prevents confusion. For example:

- Value: “Testing should be part of development, not a separate phase.”
- Action: “Use TDD for deterministic functionality.”
- Meta: “Test when it matters and when you need a safety net; consider both benefits and costs.”

### Look for hidden values

If a team clings to brittle tests, unused code, heavyweight process, or over-general architecture, the visible practice may hide a value heuristic such as:

- “Visible artifacts prove I did useful work.”
- “Deleting code risks losing knowledge.”
- “More coverage means more safety.”

Distilling the hidden value makes the practice discussable.

### Test the heuristic against counterexamples

Ask:

- Can we name a case where this advice would be harmful?
- What would have to be true for the opposite advice to be better?
- What signal tells us to stop using this heuristic?

A heuristic becomes more valuable when its boundary is clear.

## Best practices for communicating heuristics

### Choose the right level of packaging

Wirfs-Brock describes a spectrum:

- Pithy phrase: memorable but often too thin.
- QHE card: fast, concrete, shareable.
- Heuristic gist: enough context to discuss with others.
- Full pattern: best for complex, recurring design problems with rich forces and consequences.

Use the smallest form that communicates enough context.

### Use heuristic gists for team sharing

A gist sits between a QHE card and a full pattern.

Recommended structure:

1. Name
2. Problem summary
3. Context
4. Heuristic
5. Example
6. Consequences
7. Caveats / when not to use
8. Related or competing heuristics

### Communicate heuristics as invitations, not commandments

Use language like:

- “Try this when...”
- “Prefer this if...”
- “This is useful until...”
- “Watch for...”
- “Avoid this when...”

Avoid:

- “Always...”
- “Never...”
- “Best practice...” without context
- “The right way...”

### Include examples and counterexamples

Examples make heuristics memorable. Counterexamples keep them honest.

### Encourage discussion of edge cases

Wirfs-Brock explicitly recommends using written heuristics to stimulate deeper discussion about nuances, counterexamples, edge cases, and competing heuristics. The conversation is part of the value.

## Team practice: a heuristic-capture workshop

### 1. Select a design episode

Pick a recent decision: a refactoring, architecture choice, test strategy, event model, API boundary, or production fix.

### 2. Reconstruct the story

Ask participants to describe:

- The problem
- The constraints
- Options considered
- What they tried
- What they avoided
- What changed their mind
- What they learned afterward

### 3. Extract candidate heuristics

Listen for sentences like:

- “Usually we...”
- “We avoid...”
- “When this happens, try...”
- “That works unless...”
- “The smell is...”
- “The important thing is...”

### 4. Write QHE cards

Write one card per heuristic. Keep them rough.

### 5. Distill and test

For each card, ask:

- Is this action, value, or meta?
- What is the context?
- What are the forces?
- What are the consequences?
- What competing heuristic exists?
- When would this fail?

### 6. Publish as gists

Add the best heuristics to a shared team knowledge base. Keep them short enough to read and rich enough to apply.

### 7. Revisit after use

A heuristic should evolve. Add field notes when it succeeds, fails, or needs refinement.

## Anti-patterns

- **Slogan capture:** Recording “keep it simple” without context, examples, or tradeoffs.
- **Rule laundering:** Turning fallible judgment into mandatory policy.
- **Expert mystique:** Accepting advice without asking when it fails.
- **Context stripping:** Sharing a heuristic detached from the situation that made it work.
- **Premature pattern writing:** Spending too much effort formalizing before the heuristic has been tested.
- **Practice-value confusion:** Debating a practice while ignoring the value it serves.
- **Ignoring observed behavior:** Capturing only what people say they do, not what they actually do.

## Practical checklist

A useful captured heuristic should answer:

- What question does it help answer?
- What action or attitude does it recommend?
- In what context does it apply?
- What forces does it balance?
- What example makes it concrete?
- What consequences should we expect?
- When should we not use it?
- What competing heuristic might apply instead?
- How will we know whether it helped?

## Source trail

Primary Rebecca Wirfs-Brock sources consulted:

- “Growing Your Personal Design Heuristics Toolkit” — https://wirfs-brock.com/rebecca/blog/2019/03/21/growing-your-personal-design-heuristics/
- “What do typical design heuristics look like?” — https://wirfs-brock.com/rebecca/blog/2019/04/04/what-do-typical-design-heuristics-look/
- “Writing, Remembering, and Sharing Design Heuristics” — https://wirfs-brock.com/rebecca/blog/2019/04/13/writing/
- “Nothing ever goes exactly by the book” — https://wirfs-brock.com/rebecca/blog/2019/04/19/nothing-ever-goes-exactly-by-the-book/
- “What we say versus what we do” — https://wirfs-brock.com/rebecca/blog/2019/04/25/what-we-say-versus-what-we-do/
- “Testing, Testing...our Heuristics” — https://wirfs-brock.com/rebecca/blog/2023/04/19/testing-testing-our-heuristics/
- “Our Heuristics are Shaped Through Experience” — https://wirfs-brock.com/rebecca/blog/2023/05/02/our-heuristics-are-shaped-through-experience/
- “Getting out of your ruts” — https://wirfs-brock.com/rebecca/blog/2023/05/04/getting-out-of-your-ruts/
- “Cultivating Your Design Heuristics” — https://wirfs-brock.com/rebecca/presentations/cultivatingHeuristics2017/
- “Distilling Your Design Heuristics: A Report and a Challenge” — https://wirfs-brock.com/rebecca/presentations/DistillingHeusristics2018/
