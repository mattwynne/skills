# A3 problem-solving: carry an improvement through to learning

A3 is a Toyota/Lean approach to understanding a problem, agreeing on countermeasures, testing them, and learning from the results. Its name comes from the A3-sized sheet of paper traditionally used to tell the problem-solving story.

The sheet is a thinking and discussion aid, not the method itself. A polished report written after choosing a fix misses the point. Build and revise the account as evidence emerges, involving the people who do the work and those affected by the change.

[Five Whys](five-whys.md) is one tool for the cause-analysis part of an A3. A3 supplies the wider cycle: Plan–Do–Check–Act (PDCA).

## Build the problem-solving story

There is no single mandatory layout. Cover these questions concisely:

| Part | Questions to answer |
| --- | --- |
| Background | Why does this problem matter? Who is affected? |
| Current condition | What actually happens? What evidence shows the frequency, impact, and gap from expectations? |
| Target condition | What observable result would count as improvement, and by when? |
| Cause analysis | What mechanisms explain the gap? Which explanations are supported, and which remain hypotheses? |
| Countermeasures | What changes address those mechanisms? What alternatives and trade-offs did we consider? |
| Implementation | Who will do what, by when? What approvals, safeguards, or rollback steps are needed? |
| Follow-up | How and when will we check results? What will we retain, adjust, or investigate next? |

Use [Five Whys](five-whys.md#how-to-use-it) when it helps connect observations to causes. Investigate both how the defect was produced and how it escaped detection. Do not force every problem into a single causal chain.

## Choose countermeasures, not just repairs

“Countermeasure” emphasises that a proposed change is a hypothesis to test, not a guaranteed permanent solution. State the prediction: **if we change X, outcome Y should improve because of mechanism Z.**

Separate immediate correction, detection or containment, and prevention; see the [Five Whys defect-prevention distinction](five-whys.md#defect-prevention-occurrence-and-escape). Restoring a failed run may be necessary, but it does not establish that the next run will succeed.

Prefer quality at the source: change the work so defective output is harder to produce, and make abnormalities visible before they propagate. Mistake-proofing (*poka-yoke*) can help—for example, making required handoff metadata part of a structured artifact rather than relying on memory. Keep detection as a complementary safeguard.

For an illustrative missing-artifact failure, the hypothesis might be: making evidence creation part of structured stage output will reduce omitted artifacts; a handoff gate will stop any remaining omissions reaching review. These are separate claims and need separate checks.

## Check results and sustain the improvement

Before implementing, choose a baseline, a success measure, and a review point. For a handoff change, measure artifact omissions and downstream missing-artifact failures separately, and watch for added retries or blocked valid handoffs.

- **Plan:** describe the gap, investigate causes, and predict the countermeasure's effect.
- **Do:** apply the smallest safe change or experiment.
- **Check:** compare observed results with the prediction. Tests can validate a mechanism; representative workflow runs show whether it improves actual work.
- **Act:** retain and document a successful change, or revise the hypothesis and try again. Apply the learning to similar handoffs where the same mechanism exists.

Do not equate “change merged” with “prevention demonstrated.” If effectiveness needs later observation, record the owner, review point, and pending evidence. Do not invent measurements or commitments on someone else's behalf.

## Use within Kaizen Fix

Follow the [Kaizen Fix workflow](SKILL.md#investigation-workflow); A3 complements its debugging and validation steps rather than replacing them.

For a small, obvious fix, a concise resolution section can carry the A3 reasoning. For a recurring, costly, or cross-stage problem, make the current condition, target, alternatives, and follow-up explicit. A separate A3 document is optional, not a new paperwork requirement.

Preserve the original kaizen observation. Append the evidence, countermeasure, validation, and follow-up; distinguish implementation complete from effectiveness still awaiting review. Scale the investigation to the problem without skipping the learning loop.
