# Five Whys: investigate causes, not blame

Five Whys is a Toyota problem-solving technique for moving from an observed problem to the conditions that produced it. Ask why the problem occurred, investigate the answer, then ask why that condition existed. Use it within the cause-analysis stage of [A3 problem-solving](a3-problem-solving.md), not as a substitute for the whole improvement cycle.

## How to use it

1. State the specific observation: what happened, where, when, and with what impact. Avoid embedding a presumed cause or fix in the problem statement.
2. Ask what caused that observation. Inspect the actual work: logs, inputs, code, handoffs, and the people doing the work.
3. Record the answer and its evidence. Label an untested explanation as a hypothesis; decide what observation or experiment could confirm or refute it.
4. Ask why that condition existed. Follow multiple branches when several conditions contributed.
5. Stop when you have an evidence-supported causal mechanism and a useful point of intervention. Five is a prompt, not a required count.
6. Test a countermeasure and check whether it prevents recurrence. Use the [A3 follow-up process](a3-problem-solving.md#check-results-and-sustain-the-improvement) to carry the investigation through to learning.

Do not manufacture a complete chain when evidence runs out. Record what remains unknown and the next investigation step. Causes outside this repository still matter; distinguish immediate local protection from changes that need another owner.

## Example: a workflow handoff failure

This is an illustrative chain, not a finding about this repository:

- **Why did the review stage fail?** It could not find the implementation evidence file.
- **Why was the file missing?** The implementation stage handed off without creating it.
- **Why could that stage hand off?** Success depended on the agent's completion message, not the presence of the required artifact.
- **Why wasn't the artifact checked?** The handoff requirement existed only in prose; the workflow had no executable check.

Four questions expose an actionable mechanism. Confirm each link before adopting this explanation. Adding a handoff check may prevent an invalid transition, but does not explain every reason an agent might omit the file; investigate that branch if it remains a recurring problem.

## Defect prevention: occurrence and escape

Investigate two questions separately:

- **Occurrence:** why was the defective output produced?
- **Escape:** why did it pass through to the next stage or customer?

Then distinguish the actions:

| Action | Purpose | Example |
| --- | --- | --- |
| Correction | Repair this instance | Recreate the missing evidence file |
| Detection or containment | Catch or limit defective output | Reject a handoff whose required artifact is missing |
| Prevention | Change the conditions that produce defective output | Make artifact creation part of the stage's structured output rather than a separate, forgettable step |

A gate can prevent downstream failure while still only detecting an upstream defect. State which boundary the countermeasure protects. A regression test is valuable, but passing it alone does not prove the defect-producing process has improved.

## Pitfalls

- **Blame:** “The agent/operator forgot” describes an event, not a sufficient explanation. Ask what made omission possible and what safeguards were absent.
- **A single root cause at any cost:** complex failures often need a causal map with several branches.
- **Plausible stories:** repeated “why” questions do not establish causality without evidence.
- **Choosing the fix first:** investigate before steering the chain toward a preferred tool, prompt, or process change.
- **Endless abstraction:** prefer a specific mechanism over conclusions such as “poor communication” or “insufficient care.”

For the full path from investigation to a tested, sustained improvement, see [A3 problem-solving](a3-problem-solving.md). Return to the [Kaizen Fix workflow](SKILL.md#investigation-workflow) to apply it to a kaizen note.
