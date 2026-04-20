---
title: Prompt Caching Tiers — 5-minute vs 1-hour
added: 2026-04-20
tags: [claude-code, prompt-caching, cost-optimization, api]
source: https://platform.claude.com/docs/en/docs/build-with-claude/prompt-caching
---

# Prompt caching tiers — 5-minute vs 1-hour

Anthropic's prompt cache has two TTLs: the default 5-minute ("ephemeral") tier and the opt-in 1-hour ("ephemeral with ttl=1h") tier. Picking the right one can change your spend by 2–10× for long-running workflows. This note covers the mechanics, the pricing math, and when each tier actually pays off.

## TL;DR

- **Default is 5-minute.** Cheaper write (1.25× base), auto-refreshes on every hit. Good for interactive work where you're probably still typing within 5 minutes.
- **1-hour costs 1.6× more to write** (2× base vs 1.25× base) but earns its keep if you'd otherwise miss a 5-minute window. Good for long-running agent loops, parallel subagent dispatch, deep reviews with think-time.
- **Reads are identical** for both tiers: 0.1× base. Cache hits are always cheap.
- **Break-even is a single saved re-fill.** If choosing 1h prevents even one cache miss that would have forced a full re-fill (1× base for the whole prompt), 1h wins.

## Pricing (multipliers on base input token rate)

| Token class | 5-minute tier | 1-hour tier |
|---|---|---|
| Base input (no cache) | 1.0× | 1.0× |
| Cache write | **1.25×** | **2.0×** |
| Cache read (hit) | **0.1×** | **0.1×** |

Worked example for **Opus 4.7** at $5/MTok base input:

| Operation | 5m tier | 1h tier |
|---|---|---|
| Write (first prompt fill) | $6.25/MTok | $10.00/MTok |
| Hit (subsequent calls) | $0.50/MTok | $0.50/MTok |
| Miss (expired; must re-fill) | $6.25/MTok | $10.00/MTok |

## Mental model for the math

Write cost once; read costs 0.1× per hit forever (until TTL expires and the cache evicts). So for a prompt of *P* tokens called *N* times:

- **No caching:** $N \cdot P \cdot 1.0 = NP$ (billed as full base on every call)
- **5m tier, all hits:** $P \cdot 1.25 + (N-1) \cdot P \cdot 0.1 = P(1.25 + 0.1(N-1))$
- **1h tier, all hits:** $P \cdot 2.0 + (N-1) \cdot P \cdot 0.1 = P(2.0 + 0.1(N-1))$

**Crossover point where 1h beats 5m:** when one expired-cache refill at 5m matches or exceeds the extra 0.75× write cost at 1h. Concretely: if there's even a ~75% chance that you'll exceed the 5-minute window and need to refill at 1.25×, you're already better off paying 2× once.

In agent workloads with think-time between turns, this is almost always true. In interactive chat where you're typing continuously, 5m is fine.

## Cache invalidation rules

The cache is hierarchical: `tools → system → messages`. A change at any level **invalidates everything below it.**

**Full invalidation (cache cleared):**
- Tool definitions change (name, description, params, order)
- Web search toggle flipped
- Citations toggle flipped
- Speed setting changes (fast ↔ standard)
- Images added or removed *anywhere* in the prompt
- Thinking parameters change (enabled/disabled, budget changed)
- Non-tool-result user content added during extended thinking

**Cache survives:**
- `tool_choice` parameter changes
- Tool results added (without other user content changes)

The practical implication: **tool definitions should stabilize across a long workflow.** If you rebuild your tool list every turn (e.g., adding a new MCP server, toggling a capability), every turn is a cache miss. Freeze tool shape for the duration of the workflow when you can.

## Cache breakpoints and minimum sizes

- **Max 4** explicit `cache_control` markers per request
- **Lookback 20** blocks per breakpoint (the system checks 20 positions back for a prior cache entry)
- **Minimum cacheable tokens per model:**
  - Opus 4.7, 4.6, 4.5 → **4,096 tokens**
  - Sonnet 4.6 → **2,048 tokens**
  - Sonnet 4.5 / 4 / 3.7, Opus 4.1 / 4 → **1,024 tokens**
  - Haiku 4.5 → **4,096 tokens**

If your cached chunk is below the minimum, the cache marker is ignored and you pay base rate. This matters most for the Opus 4.7 tier's 4096-token floor — short system prompts don't cache at all.

## Enabling the tiers

### In raw API calls

```json
// 5-minute (default, implicit)
{ "cache_control": { "type": "ephemeral" } }

// 1-hour (explicit opt-in)
{ "cache_control": { "type": "ephemeral", "ttl": "1h" } }
```

### In Claude Code

Env vars on the shell / session:

```bash
# Opt into 1-hour cache TTL (API key, Bedrock, Vertex, Foundry)
export ENABLE_PROMPT_CACHING_1H=1

# Force 5-minute TTL if you've globally opted in but want shorter for a specific session
export FORCE_PROMPT_CACHING_5M=1
```

Put `ENABLE_PROMPT_CACHING_1H` in your shell rc (or `.claude/session-env/`) when you habitually run long-form agent workflows. Leave it off for interactive coding work where you're in the context every few seconds anyway.

## Mixing tiers in one request

You can combine 1h and 5m cache breakpoints in the same request. Two constraints:

1. **1h breakpoints must precede 5m breakpoints** in the prompt.
2. **Billing uses three positions:** A = highest hit, B = highest 1h block, C = last block. Reads billed at A; 1h writes billed for (B–A); 5m writes billed for (C–B).

Rule of thumb: put *stable* content (system prompt, tool defs, background corpus) at the 1h breakpoint and *session-scoped* content (accumulating conversation history, current-turn notes) at the 5m breakpoint. That way the expensive foundation never re-fills, and only the cheaper session tail does.

## When to pick which

### Use the default (5-minute)

- Interactive chat where you're typing continuously
- System prompt used more than once per 5 minutes (auto-refresh is free)
- Short coding iterations (< 5 min between turns)
- You don't want to think about it — it's the default for a reason

### Opt in to 1-hour (`ENABLE_PROMPT_CACHING_1H=1`)

- **Long-running agentic workflows** — subagents that work for minutes, then return results to a parent that thinks for minutes more
- **Parallel subagent dispatch** — the parent session sits idle while 5 subagents do work; a 5-minute cache would expire before they all return
- **Unpredictable user response time** — open review sessions, legal analysis, research reading where you'll come back to the same context later
- **Rate-limit headroom matters** — cache hits don't count against input rate limits, so aggressive caching of large background corpora can avoid throttling
- **Persistent chat histories** — long multi-hour conversations where the accumulated history is expensive to re-fill

### Neither tier

- Extremely short prompts (below the model's minimum cacheable size — usually 4096 tokens on the current flagships)
- One-off calls with no reuse
- Prompts where tool definitions or images change every turn (cache invalidates anyway)

## Gotchas

- **Cache-write on cold prompts is more expensive than no caching at all** (1.25× or 2× vs 1×). If you never hit the cache even once, you paid a premium for nothing. Only opt in when you actually expect reuse.
- **`tool_choice` doesn't invalidate the cache**, but changing the *set* of tools does. Rebuilding the tool list each turn is a silent cache-killer.
- **Thinking mode flips invalidate.** If your skill sometimes enables extended thinking and sometimes doesn't, you're thrashing the cache. Pick a mode per session.
- **Image presence matters more than image content.** Removing an image from anywhere in the prompt invalidates. If your prompts sometimes have images and sometimes don't, consider a stable placeholder to maintain image-presence parity.

## See also

- [Anthropic prompt caching docs](https://platform.claude.com/docs/en/docs/build-with-claude/prompt-caching) — canonical source for pricing and mechanics.
- `claude-code/notes/claude-code-2026-features.md` — where `ENABLE_PROMPT_CACHING_1H` is introduced as a Claude Code env var.
