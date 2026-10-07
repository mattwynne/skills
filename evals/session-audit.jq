# Input: the continued native session. Arguments: seed, events, inputs, condition.
. as $session |
$session[($seed | length):] as $added |
[$added[] | select(.type == "message") | .message] as $messages |
[$messages[] | select(.role == "assistant") | .content[]? | select(.type == "toolCall")] as $calls |
[$messages[] | select(.role == "toolResult")] as $results |
([$events[] | select(.type == "message_end" and .message.role == "assistant") | .message] | last) as $final |
([$messages[] | select(.role == "assistant")] | last) as $persisted_final |
[$inputs[0][] as $input | {
  path: $input.path,
  fully_read: any($calls[];
    . as $call | $call.name == "read" and $call.arguments.path == $input.path and
    any($results[]; .toolCallId == $call.id and .isError != true and
      ([.content[]? | select(.type == "text") | .text] | join("\n") |
        contains($input.content | sub("\n+$"; ""))))
  )
}] as $reads |
[$calls[] | select(.name != "read" or
  (.arguments.path as $path | any($inputs[0][]; .path == $path) | not)) |
  {name, arguments}] as $unexpected |
([$final.content[]? | select(.type == "text") | .text] | join("\n")) as $response |
{
  history_unchanged: ($session[:($seed | length)] == $seed),
  new_compactions: ([$added[] | select(.type == "compaction")] | length),
  new_context_edits: ([$added[] | select(.type == "context_edit")] | length),
  final_stop_reason: $final.stopReason,
  final_persisted: ($final != null and $final == $persisted_final),
  response: $response,
  reads: $reads,
  calls: [$calls[] | {name, arguments}],
  unexpected_calls: $unexpected,
  system_messages: [$messages[] | select(.role == "system") | del(.timestamp)],
  model: $final.model,
  provider: $final.provider,
  usage: $final.usage
} |
.valid = (
  .history_unchanged and .new_compactions == 0 and .new_context_edits == 0 and
  .final_stop_reason == "stop" and .final_persisted and
  (.model | type == "string" and length > 0) and (.provider | type == "string" and length > 0) and
  (.response | test("\\S")) and (.unexpected_calls | length == 0) and
  (if $condition == "control" then (.calls | length == 0)
   else all(.reads[]; .fully_read) end)
)
