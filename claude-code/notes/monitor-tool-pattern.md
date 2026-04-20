---
title: The Monitor Tool — Streaming Events from Background Processes
added: 2026-04-20
tags: [claude-code, monitor, background-process, subagents, automation]
---

# The Monitor tool pattern

The Monitor tool (shipped in Claude Code Q2 2026) turns each line of a background process's stdout into a notification Claude can react to. It replaces the old "kick off a background shell then poll for completion" loop with a stream-driven one. This note covers when to reach for it, how it changes the shape of agent workflows, and a few patterns that work well in practice.

## What it does

- You run a command in the background via the `Bash` tool with `run_in_background: true`, or dispatch a subagent with `run_in_background: true`.
- You invoke Monitor on the resulting shell/task ID. Each new line emitted to stdout/stderr becomes an event delivered back to Claude as a notification.
- Claude doesn't sleep or poll. It reacts per-line — either continuing other work, taking an action triggered by specific output, or terminating the monitor when the job finishes.

## Why it matters

Before Monitor, the idiom was:

```
1. Bash(run_in_background: true, command: "long-running thing")  → shellId
2. Sleep 30
3. Bash(command: "Read shell output of shellId")
4. If not done, go to step 2.
```

Polling wastes turns, wastes prompt cache (every poll is a new turn with stale context), and delays reaction to failures that surface in-progress. Monitor collapses this into a stream:

```
1. Bash(run_in_background: true, command: "long-running thing")  → shellId
2. Monitor(task_id: shellId)
3. [Claude does other work while events trickle in]
4. On a trigger line ("BUILD FAILED", "Tests: 100/100 passed"), act.
5. When the process exits, stop monitoring.
```

Net result: the parent session stays productive while work happens in the background. Cache stays warm. Failures surface as soon as they appear in output, not when polling happens to catch them.

## When to use it

### Good fits

- **Long-running builds / tests.** `cargo build --release`, `pytest -n auto`, `playwright test`. You want to know immediately if a test fails, not 30 seconds later.
- **Background subagent dispatch.** Spawn 5 parallel subagents for independent work (e.g., converting 5 PDFs to markdown). Monitor their completion notifications rather than sleeping until they all finish.
- **Log tailing.** Watching `tail -f` of a dev server log and reacting to error patterns.
- **Deployment pipelines.** Streaming output of `kubectl rollout status` or a Terraform apply. React to "timeout" or "failure" lines immediately.
- **Polling loops you'd otherwise write yourself.** Anywhere you'd have done `while condition; do sleep 5; check; done`, Monitor usually beats it.

### Not good fits

- **One-shot fast commands.** A `git status` or `ls` doesn't need Monitor; just run `Bash` without `run_in_background`.
- **Processes with no stdout.** Monitor needs something to stream. Silent processes (a daemon that only writes to a log file you don't tail) give you nothing.
- **High-volume output firehoses.** Monitor streams every line as an event. A process emitting 10,000 lines/sec of debug logs will drown Claude in noise. Filter upstream (`grep -E "ERROR|WARN"`) or redirect to a file and tail the filtered view.

## Patterns that work well

### Pattern 1: Dispatch-many + monitor-each

Classic parallel work. Spawn N subagents in one turn with `run_in_background: true`, then Monitor each. Claude can reason about incoming results without dedicating a whole turn to each poll.

```
Parent turn:
  - Agent(description="convert PDF 1", run_in_background: true) → aid_1
  - Agent(description="convert PDF 2", run_in_background: true) → aid_2
  - Agent(description="convert PDF 3", run_in_background: true) → aid_3
  - Monitor(task_id: aid_1, aid_2, aid_3)

Stream of events arrives; parent continues writing unrelated code / README.
When each completion event fires, parent stages the subagent's output.
```

### Pattern 2: Tail-a-log-with-trigger-lines

Run a dev server or watcher in the background; monitor its log; react only to specific trigger patterns.

```bash
# In background
npm run dev 2>&1 | tee dev.log

# Then
Monitor(task_id: devShellId)
```

Claude watches and reacts only when it sees "Error:", "listening on port", "compilation failed" — not when it sees 500 mundane "GET /favicon.ico 200" lines. The signal/noise ratio depends entirely on the log's verbosity; filtering at source (`grep -E "Error|warn"`) often beats filtering after.

### Pattern 3: Build-then-test-then-deploy chain

Sequential pipeline where each step's output decides whether to proceed. Traditionally this lived in a shell script; Monitor lets Claude make the decision live.

```
1. Bash(run_in_background: true, cmd: "make build") → buildId
2. Monitor(task_id: buildId)
   - On "BUILD SUCCESS" → proceed to step 3
   - On "BUILD FAILED" → stop, read errors, propose fix
3. Bash(run_in_background: true, cmd: "make test") → testId
4. Monitor(task_id: testId)
   - On "100% passed" → proceed
   - On any failure → stop, inspect
5. ...
```

Same logic you'd write in a shell script, but Claude can debug failures inline instead of you scrolling through CI output after the fact.

### Pattern 4: Background agent + proactive cancel

If Claude decides mid-stream that the approach is wrong, it can stop the task without waiting for completion. Useful for speculative long-running work.

```
1. Agent(run_in_background: true, task: "search approach A") → aidA
2. Agent(run_in_background: true, task: "search approach B") → aidB
3. Monitor both.
4. First subagent that shows promising output → TaskStop the other.
```

Saves compute on the losing branch.

## Guardrails

- **Always stop monitoring explicitly.** Once a process exits or you've seen what you need, stop the monitor — leaving it open wastes context on trickling events you no longer care about.
- **Cap event volume.** If a process emits more than ~50 lines/minute of meaningful output, you probably want to filter upstream or redirect to a file. Monitor isn't a log aggregator.
- **Don't monitor what you can't read.** Binary output, giant JSON blobs per line, or unstructured megablobs aren't useful events — they just fill context.
- **Don't monitor and sleep.** If you're using Monitor, you shouldn't also be running sleep loops. Pick one model.

## Interaction with other background tools

- **ScheduleWakeup** — fires a single notification after a fixed delay. Use when you have nothing to stream but want to come back later (e.g., "check the deploy in 10 min"). Monitor is for streams; ScheduleWakeup is for a single delayed ping.
- **TaskStop** — terminates a running background task. Useful for cancelling a subagent or killing a monitored process before it finishes.
- **`Bash(run_in_background: true)` + read-output-later** — still valid for simple cases where you just want to fire-and-forget and grab the output at the end. Monitor is when you want to react *during* the run.

## Debugging

- **Monitor fires no events:** Check that the process actually writes to stdout (not a log file). Redirect if needed (`2>&1 | tee -a stream.log`).
- **Monitor fires too many events:** Filter at source. `grep` / `awk` before the stream hits Monitor.
- **Events arrive out of order or duplicated:** Usually a sign of two processes writing to the same stream. Separate them or tag output with prefixes you can disambiguate.

## Cross-references

- `claude-code/notes/claude-code-2026-features.md` — where Monitor is introduced alongside the Q2 2026 feature set.
- `claude-code/templates/hooks/example-on-stop.sh` — hooks and Monitor are complementary. Hooks fire on Claude Code lifecycle events (Stop, tool-use, etc.); Monitor fires on arbitrary process output.
- `claude-code/notes/hooks-and-automation.md` — the broader "when to use hooks vs slash commands vs subagents vs memory" decision tree; Monitor adds another leaf for streaming patterns.
