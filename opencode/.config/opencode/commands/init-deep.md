---
description: Initialize or refresh AGENTS.md — parallel explore subagents gather intel, primary synthesizes
---
Create or update `AGENTS.md` for this repository, delegating discovery to parallel explore subagents so your own context stays lean.

User-provided focus or constraints (honor these):
$ARGUMENTS

## Phase 0: Scale check (fast, before spawning)

One bash call: file count (exclude node_modules/.git/dist/build/venv), existing `AGENTS.md`/`CLAUDE.md` paths, top-level dir listing. Read any existing instruction files now — their guidance must survive this run.

## Phase 1: Fire explore agents in parallel

In a SINGLE turn, launch 4 explore subagents concurrently via the task tool (no background flag needed — parallel calls in one message run concurrently). Each returns a compact report; they must NOT write anything.

1. **Structure & stack** — "Map the real project layout, languages, frameworks, and major entrypoints. Report only what deviates from standard patterns for this stack."
2. **Commands & toolchain** — "Extract exact dev/build/test/lint/typecheck/codegen commands from manifests, CI workflows, task runners. Include how to run a single test and any required command order."
3. **Conventions & quirks** — "Find project-specific conventions from config files (.eslintrc, pyproject.toml, .editorconfig, formatters), codegen/migrations/generated-code workflows, special env loading. Only deviations from defaults."
4. **Anti-patterns & gotchas** — "Grep for 'DO NOT', 'NEVER', 'ALWAYS', 'FIXME', 'DEPRECATED', 'HACK' comments and existing instruction files. List explicitly forbidden patterns and operational gotchas."

Adapt agent count to scale: tiny repo (<50 files) → 2 agents (merge 1+3, 2+4); monorepo → +1 per major package.

## Phase 2: Write while agents run

While waiting, personally read only the highest-value files the scale check surfaced (README, root manifest, one or two wiring files). Do not duplicate the agents' scopes.

## Phase 3: Synthesize AGENTS.md

Merge everything, then apply these writing rules strictly:

- Every line must answer "Would an agent likely miss this without help?" — otherwise omit
- Include: exact commands, non-obvious quirks, command order, package boundaries, anti-patterns found in this repo, pointers to existing instruction sources
- Exclude: generic advice, tutorials, obvious conventions, anything you could not verify
- Telegraphic style, short sections, bullets; simple repo → short file
- If `AGENTS.md` exists: improve in place — preserve verified guidance, delete stale claims. Never blindly rewrite.
- If the repo is a monorepo with major packages: one 30–80 line `AGENTS.md` per package, **never repeating parent content**

## Final report

List files written/updated with line counts and the hierarchy, e.g.:

```
AGENTS.md (root, N lines) — updated
packages/foo/AGENTS.md (N lines) — created
```
