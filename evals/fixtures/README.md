# Recorded-session fixture

`memba-progress.session.jsonl` comes from a real Memba coding session on 14–15 September 2026. It captures work on two production incidents, immediately before the agent reports progress. This is a native Pi session, not a constructed transcript or rewritten summary.

Run it from a checkout with Bash, `jq`, Pi and credentials for the chosen model:

```sh
./evals/replay-session.sh evals/memba-progress.json
```

Use `MODEL=provider/model` to choose another available model. No Memba checkout, globally installed skill, private session file, or local case configuration is needed.

## What was kept

The fixture contains the original latest compaction summary and the entries Pi retains after it, including assistant thinking text, tool calls/results, and custom messages. The recorded thinking setting is preserved. The original final reply is included so the case can identify where to stop; the runner withholds it from both continuations.

Unused older history was omitted. Parent links were reconnected to make the retained entries a standalone session; message IDs, timestamps, code, and debugging history remain intact. Header identity and working-directory metadata are portable, and the case runs from the skills checkout.

## What was redacted

- Four live club, group, and membership UUIDs were replaced consistently with dummy UUIDs, preserving prefixes and relationships.
- Live club and verification-group labels were replaced with fixture labels, including a remaining mention in assistant thinking.
- Provider-generated thinking, tool-call, and text signatures were removed. They contained opaque data and are not needed for replay with the configured model. Plaintext thinking remains.

Invented names and secrets in public test code were left intact. Historical local paths are quoted debugging context, not runtime dependencies. No images remain in the fixture. The private original-to-placeholder mapping is not committed.

During export, Pi’s native context builder verified that removing unused history did not change the model-visible messages or recorded settings. Its cross-model message conversion then verified that signature removal left the configured model’s input unchanged, apart from the declared value replacements. This equivalence check applies to `openai-codex/gpt-6.1-sol`; other models can interpret historical thinking differently.

`memba-progress.manifest.json` records the fixture hash, sizes, IDs and redaction counts without the original live values. Publication review found no confirmed exposed private password or API key; that is a bounded review, not a guarantee that arbitrary future session logs are safe to publish.

## Offline fixture check

```sh
./evals/test-fixture.sh
./evals/test-fixture-guards.sh
```

These check the bundled input paths, standalone native tree, withheld reply, preserved thinking setting, declared placeholder IDs, and absence of opaque signatures or image blocks. The guard tests deliberately damage those inputs and require failure. The replay runner’s tests check continuation and read evidence separately. Neither check grades communication quality.
