---
title: Evaluating Agents
added: 2026-04-19
tags: [agents, evaluation, practice]
source: https://lilianweng.github.io/posts/2023-06-23-agent/
---

# Evaluating Agents

How do you know your agent is actually good? Not "does it feel good when I demo it," but: does it work on the distribution of tasks you care about, and is it getting better or worse over time?

## Offline benchmarks vs online metrics

- **Offline benchmarks.** Fixed task sets with known answers or graders. Reproducible, cheap per run, good for regression testing. Risk: you overfit to the benchmark and ship something that fails in the wild.
- **Online metrics.** Real traffic, real users. Task-completion rate, retry rate, escalation rate, thumbs-up/down. Ground truth lives here. Noisy, slow to attribute, requires instrumentation you don't have yet.

You want both. Offline for "did my change break anything?" Online for "are we solving real problems?"

## What to measure

- **Task-completion rate.** Did the agent finish? Decompose by task type — overall is usually too blurry to act on.
- **Hallucination rate.** Did the agent invent facts, tool calls, or citations? For RAG systems, measure faithfulness: every claim must trace to a retrieved chunk.
- **Tool-use correctness.** Right tool, right args, right order. Separate "picked the wrong tool" from "picked the right tool with bad args." The fixes differ.
- **Steps to completion.** How many loop iterations? An agent that takes 40 steps to do what another takes 5 is burning money even when both succeed.
- **Cost per task.** Tokens in, tokens out, tool-call count. Track per-task-type, not just in aggregate.
- **Latency per task.** p50 and p95. Averages lie.
- **Failure modes by category.** Not "failure rate = 12%" but "8% hit tool-error ceiling, 3% loop-stagnated, 1% produced wrong answer." The categories tell you what to fix.

## LLM-as-judge: the caveats

Scaling human evaluation is expensive. Using an LLM to grade outputs is tempting and often useful, but:

- **The judge has biases.** Preference for longer answers, preference for hedged answers, preference for the same model's style. Measure judge-human agreement before trusting judge scores.
- **Judge and generator should be different models.** Same model grading itself has a systematic bias toward its own outputs.
- **Structured rubrics > free-form "rate 1–5."** "Does the answer cite at least one source? Y/N. Does the cited source support the claim? Y/N." beats "is this good?"
- **Calibrate with human eval.** Score a sample both ways. If they disagree more than 15-20% of the time, your rubric or your judge is broken.

LLM-as-judge is a cheaper *proxy*, not a replacement. Treat it as you'd treat a noisy measurement instrument.

## Human-in-the-loop eval

Still the gold standard. Budget for it even when you also run automated eval.

- **Structured review sessions.** Same rubric the LLM-judge uses, applied by a person. Gives you the calibration data.
- **Failure triage.** Sample N failures per week; tag by category; prioritize fixes by frequency × severity.
- **Spot-check successes.** "Successful" by automated metric doesn't mean actually good. Sample passing cases too — you'll find the ones that passed for the wrong reason.

## Gold-standard traces

For agent systems specifically: maintain a set of reference trajectories (Thought–Action–Observation sequences) for canonical tasks. When the agent's trace diverges significantly, investigate. Doesn't have to be character-identical — the point is to surface "the agent used to do this in 3 steps, now it takes 8."

## Practical: how do YOU know your agent is good?

The usual failure mode isn't "we have no eval." It's "we have eval we don't trust and don't act on." Some tactics:

- **Small eval set > grand benchmark.** 30 hand-curated tasks you understand deeply, graded carefully, beats 1000 tasks from a public benchmark that don't match your domain. You want something you can eyeball in an afternoon.
- **Run eval on every change.** If it's not automated in CI, it doesn't exist.
- **Track regressions over time.** Not just "current score is X" but "score by week." A slowly-degrading agent is the most common production failure and the easiest to miss without a trend line.
- **Keep a cold set.** Tasks you don't look at during development. Periodically grade. Divergence between warm and cold tells you how badly you're overfitting.
- **Dogfood.** Use the agent yourself, on your own work, daily. No eval catches what daily use catches. If the team building it won't use it, nothing else matters.
- **Failure gallery.** A living doc of the 20 worst failures. When you see the same failure three times, promote it to an eval case. When you fix it, add the fix as a regression test.

## The one-question test

When you ship a change and the numbers move, can you explain why? If yes, your eval is working. If you're squinting at a dashboard guessing, your eval is theater.
