# Talking to humans: supporting evaluation cases

## What we are testing

Can a person understand the message without unpacking jargon or reconstructing the agent’s private working context?

Plain language must preserve the facts. A shorter message that hides the problem does not pass. Neither does a longer message that explains everything except what the person needs to know.

The tone checks draw on [Use the words normal people would use](https://gilest.org/notes/normal-words.html) and [Use the human voice, not the corporate voice](https://gilest.org/notes/human-voice.html). We test both ordinary words and a natural, person-to-person voice.

## How to run

Start with the [real-session replay](README.md): continue native Pi session copies, explicitly load the skill in one, and compare the replies yourself. This preserves the working context instead of reconstructing it from a written transcript.

The cases below support that test. The machine-readable suite is `talking-to-humans.json`; it includes these seven cases plus a case checking headline-style language. The [supporting runner](constructed-cases.md) applies the rubric through an independent model judge and calibrates that judge against known failures. Its scores are not a verdict on whether the skill helps in practice.

The steps below describe the manual comparison of these constructed cases.

1. Run each case in a fresh conversation. Give the agent only the case’s **Context** and **Request**, not its checks or example answer. Context represents facts from prior work; it does not establish the human’s vocabulary unless explicitly stated.
2. First run without this skill, then run again with `skills/talking-to-humans/SKILL.md` loaded. Keep the model, other instructions, and generation settings the same.
3. Save both outputs without labeling which used the skill. Shuffle their order before judging.
4. Give a human or a separate judge the case, its checks, the rubric below, and one output at a time. Do not give the judge the skill or the example answers. Ask for a pass/fail on each criterion, with a quote supporting each failure.
5. Compare per-case results. For a less noisy comparison, repeat each condition three times and retain failures rather than choosing the best answer.

Also ask a human reader: **“What needs attention, and where?”** If their answer misses an essential fact, find out whether the wording caused that misunderstanding. Automated judging cannot establish how tiring a message feels to a human.

## Rubric

The supporting runner grades each criterion pass/fail and counts a constructed case as passing only when all checks pass. Inspect the individual judgments: that total can hide a readability improvement. For real-session comparisons, judge which reply is clearer and note factual problems separately; do not average away a factual error.

| Criterion | Pass when… |
|---|---|
| Shared language | Jargon is absent, already used by the human, clearly established in the domain, or necessary and explained in ordinary words. Exact identifiers are not treated as jargon merely because they look technical. |
| Explicit meaning | The relevant projects, files, behavior, and consequences are identifiable without guessing. Distinct concerns are not buried in compressed labels. |
| Faithfulness | The answer preserves all facts essential to the request and distinguishes completed, unchecked, possible, and undecided work. It invents no findings, decisions, or commitments. |
| Reading effort | The answer is direct and proportionate. It does not require repeated mental unpacking, obscure the point with explanations, or replace precision with vague reassurance. |
| Human voice | The answer sounds like one person talking to another, not an official notice. It is respectful and appropriate to the situation, without forced slang, jokes, or cheerfulness. Contractions are not required. |

Do not use a banned-word list, a reading-grade threshold, or an exact-match answer. The same word can be helpful in one context and needless jargon in another. Several sentences can be easier to read than one short sentence.

## Cases

### 1. Rename handoff — regression from a real conversation

**Context**

- The rename in the current repository is complete.
- Another project, `capstone-project-starter`, depends on this repository.
- You have not checked that project after the rename.
- Its `.gitignore` rules and folder paths written directly into its files might still refer to the old name. No incorrect paths have been confirmed.
- What to do about files or command arguments that refer to the old name has not been decided.
- The human has used the words “rename,” “repo,” and `.gitignore`, but has not used “legacy aliases,” “state migration,” or “hardcoded folder mapping.”

**Request**

> Give me a short handoff: what’s done, and what still needs attention?

**Checks**

- Names `capstone-project-starter` and explains why it matters.
- Identifies its `.gitignore` and folder paths as things to check, not known failures.
- Mentions the undecided handling of files or command arguments using the old name.
- Does not substitute an invented decision such as “old commands will keep working.”

**Example passing answer — illustrative, not required wording**

> The rename is done in this repo. I haven’t checked `capstone-project-starter`, which depends on it. Its `.gitignore` and folder paths may still use the old name. We also haven’t decided what to do about files or command arguments that use the old name.

**Known failing answer**

> Compatibility follow-up: review the starter’s ignore rules and any hardcoded folder mapping. Legacy aliases and state migration remain unspecified.

This fails shared language and explicit meaning. It also obscures the distinction between unchecked work and undecided behavior.

### 2. Ordinary words, still too vague

**Context**

Use the facts from case 1.

**Request**

> Is this a clear handoff? Rewrite it if needed: “The rename is done. The other project needs a look, and we still need to sort out the old stuff.”

**Checks**

- Does not treat the absence of jargon as sufficient.
- Names the dependent project and the specific checks.
- Explains “old stuff” as files or command arguments using the old name.
- Preserves uncertainty and the unresolved decision.

### 3. Technical language the human already uses

**Context**

- The human said: “We need backward-compatible CLI aliases. Did you add them?”
- You added an alias so `tool old-name` calls the same operation as `tool new-name`.
- Both commands passed their tests.
- No other behavior is relevant to the question.

**Request**

> Did you add the backward-compatible CLI alias, and does it pass the tests?

**Checks**

- Answers yes and reports that both commands passed.
- May use “CLI alias” or “backward-compatible” without defining them.
- Keeps the command names exact if it includes them.
- Does not add a glossary or imply the human needs a beginner explanation.

### 4. The agent’s jargon is not shared vocabulary

**Context**

- The human asked: “Can you make the renamed tool work with my existing files?”
- The agent previously replied: “I’ll address state migration and legacy aliases.” The human has not used or acknowledged those terms.
- You have now made the tool read existing files without the human having to change them.
- You have not added support for commands that use the old name; those commands currently fail.

**Request**

> What’s working now, and what isn’t?

**Checks**

- Says existing files work without changes.
- Says commands using the old name still fail.
- Does not rely on the agent’s earlier “state migration” or “legacy aliases” wording as evidence that the human understands it.
- Does not hide the failure behind “compatibility work remains.”

### 5. A necessary technical term for a new reader

**Context**

- The human says they are new to Git.
- The `.gitignore` file lists files and folders Git should ignore.
- It still lists the old output folder, `old-output/`, rather than `new-output/`.
- You have confirmed that generated files under `new-output/` appear as untracked files. They have not been committed.

**Request**

> Why are these generated files showing up, and which file do I need to change?

**Checks**

- Names `.gitignore` and briefly explains what it does.
- Identifies the folder-name mismatch and the change needed.
- Does not claim the generated files have been committed.
- Does not avoid the useful filename by saying only “change the settings.”

### 6. Short status without hiding the remaining work

**Context**

- The rename is complete in the current repository and its tests passed.
- `capstone-project-starter` depends on that repository and has not been checked.
- No failure in `capstone-project-starter` has been confirmed.

**Request**

> Two sentences max: are we finished?

**Checks**

- Distinguishes completion in the current repository from the unchecked dependent project.
- Names `capstone-project-starter`.
- Does not say everything is finished or claim the dependent project is broken.
- Fits the requested limit without reverting to compressed jargon.

### 7. Familiar words, corporate voice

**Context**

- The rename is complete in the current repository.
- Its tests passed.
- No action is needed from the human.
- The human prefers a straightforward update, not jokes or celebrations.

**Request**

> Make this update easier to read: “Please be advised that the requested name change has now been completed. We would like to confirm that all tests have passed. No further action is required on your part.”

**Checks**

- Preserves the completed rename, passing tests, and lack of required action.
- Sounds like a direct update from one person to another, rather than a formal notice.
- Does not merely replace individual words while keeping the stiff framing.
- Does not overcorrect into forced friendliness, slang, or celebration.
- Does not invent broader assurances such as “nothing can break now.”

## Known limits

These cases concentrate on technical handoffs after a rename, with one case checking corporate tone. They do not yet establish performance for nontechnical conversations, sensitive feedback, or domain language outside software. Add real examples as they arise, and keep some new cases out of the skill’s examples to check whether the behavior generalizes.
