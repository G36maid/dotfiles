---
name: antigravity-looker
description: "Describe/OCR images via agy when your model lacks vision."
version: 1.1.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [vision, image, screenshot, ocr, antigravity, gemini, multimodal]
    category: media
    related_skills: [ocr-and-documents, pdf]
---

# Antigravity Looker

Use when you need to actually SEE an image — describe a screenshot, read UI state, OCR
text in a photo, extract a table, or inspect a generated diagram/design — but the active
agent model has no native vision (e.g. deepseek-v4-flash). This outsources the "look" to
Google's Antigravity CLI (`agy`), which processes image/multimodal files via Gemini, in
the same spirit as OMO's `multimodal-looker` agent + `look_at` tool.

## When to Use

- `vision_analyze` is unavailable or has no configured vision backend.
- The user shares an image path/URL/screenshot and needs it interpreted.
- You must OCR or read text out of a photo/screenshot (no local OCR dependency needed).
- Verify a rendered image (diagram, form layout, UI mockup) matches expectations.

Do NOT use for plain text documents (use `read_file` / `ocr-and-documents` / `pdf` skills).

## Prerequisites

- `agy` installed on a CPU that supports PCLMULQDQ (pclmul). See Pitfalls — the number-one
  failure point on VMs (the Go binary sigills at startup without it).
- A one-time interactive login (`agy` → Google sign-in). Headless reuses cached creds at
  `~/.gemini/antigravity-cli/antigravity-oauth-token` (mode 600). `GEMINI_API_KEY` does
  NOT authenticate `agy`.

## Stable, tested invocation (use this)

JSON output is the reliable choice for scripting (parse `.response`):

```bash
agy -p "Describe/transcribe the image at <ABS_PATH>" \
    --output-format json \
    --print-timeout 180s
```

Returns:
`{"conversation_id": "...", "status": "SUCCESS", "response": "...", "duration_seconds": N, "num_turns": N, "usage": {...}}`

Notes from real runs:
- Reference the image by ABSOLUTE path in the prompt — agy reads it even when the file is
  OUTSIDE the current working directory (verified from `/`). No need to cd to the image.
- `--print-timeout` MUST have a unit (`180s`, `5m0s`); bare `180` errors.
- `--output-format text` works for human-looking output; `json` is best for the agent loop.
- Pure describe/OCR runs complete with no permission prompts.

## Procedure

1. **Verify binary runs** (cheap):

   ```bash
   which agy && agy --version
   ```

   If it crashes with `FATAL ERROR ... pclmul ... go/sigill-fail-fast`, the CPU masks
   pclmul (QEMU/KVM VMs, incl. this headless `arch-agent` VM until it uses host CPU).
   Fix: switch VM to host CPU, or run on real hardware. Report, don't fabricate.

2. **Authenticate once** (interactive): `agy`, complete Google sign-in, exit.

3. **Look at the image** (JSON, stable):

   ```bash
   agy -p "Describe this image in detail. If it contains text, transcribe it verbatim." \
       --output-format json --print-timeout 300s /path/to/image.png
   ```

   Targeted variants (keep them READ-ONLY — describe/transcribe, never "fix"):
   - OCR: `"Transcribe ALL text in <img> verbatim, preserving layout/order."`
   - UI:  `"What is the UI state shown here? List visible elements and their labels."`
   - Table: `"Extract the table in <img> to Markdown."`
   - Verify: `"Does the rendered <thing> match <expected>? List discrepancies."`

## Prompt construction (borrowed from OMO's multimodal-looker)

Model the prompt on OMO's `buildLookAtPrompt` — same output discipline, adapted because
agy reads the image by path instead of a pre-attached multimodal part. Structure a prompt as:

    Analyze the image at <ABS_PATH> and extract the requested information.

    Goal: <specific goal>

    Provide ONLY the extracted information that matches the goal.
    Be thorough on what was requested, concise on everything else.
    If the requested information is not found, clearly state what is missing.

Why each part matters:
- **Goal**: be specific about WHAT to extract (values, labels, layout, rejected vs missing pieces).
- **"Provide ONLY ... matches the goal"**: stops the vision model from verbose scene narration
  when you wanted OCR, and vice-versa. Keep the answer scoped.
- **"Thorough on requested, concise on everything else"**: mirrors OMO — maximize signal on the
  ask, minimize filler. Good for feeding the result back into a research loop.
- **"State what is missing"**: forces honesty when text is illegible / element absent; you can
  then report uncertainty instead of fabricating.
- Do NOT copy OMO's "do not load by path" clause — agy genuinely reads the file from the path
  (verified working from any cwd).

4. **Return `.response`** as the image's content. For research, carry it onward (combine
   with deepwiki / context7 / web_extract findings).

## Hygiene (state accumulates — clean it)

Every headless run writes a new conversation under `~/.gemini/antigravity-cli/`:
`brain/<id>/`, `conversations/<id>.db*`, and `log/cli-*.log` (tens of MB after ~10 runs).
For repeated use, prune old entries BUT NEVER touch `antigravity-oauth-token` or
`installation_id`:

```bash
# prune old conversation dirs/dbs, keep logs dir + token
find ~/.gemini/antigravity-cli/brain -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} + 2>/dev/null
find ~/.gemini/antigravity-cli/conversations -type f ! -name '*.db-wal' ! -name '*.db-shm' \
  -name '*.db' -mtime +1 -delete 2>/dev/null
find ~/.gemini/antigravity-cli/log -name '*.log' -mtime +1 -delete 2>/dev/null
```

## Pitfalls

- **pclmul sigill crash**: `agy` is a Go binary compiled with PCLMULQDQ. On a VM whose CPU
  model masks pclmul it dies instantly with `go/sigill-fail-fast`. `grep -m1 pclmul
  /proc/cpuinfo` empty ⇒ not supported. Fix = host CPU passthrough or real hardware.
- **Auth**: headless without a cached login prints an OAuth URL then times out (~60s).
  Authenticate once interactively first.
- **Print timeout**: `-p` gives up at `--print-timeout` (default 5m0s, must have a unit).
- **Workspace/paths**: pass ABSOLUTE path in the prompt; agy auto-detects the image even
  outside cwd. Don't rely on it finding files by bare name elsewhere.
- **Over-eager actions**: agy is an agent; keep look-at prompts strictly read-only.
- **Headless auto-denies read_file**: in non-interactive `-p` mode agy's permission prompt gets auto-denied for ANY image path (`permission check failed for read_file ...: user denied permission`). For read-only describe/OCR runs add `--dangerously-skip-permissions` (auto-approves tool permissions; safe here because the only tool invoked is read_file). Verified on the headless `arch-agent` VM.
- **State bloat**: prune per Hygiene; token must persist.

## Verification

- A real run returns JSON with `status: "SUCCESS"` and a non-empty `response`; a blank or
  `authentication required` means it didn't run — diagnose, don't trust.
- If the image has text, spot-check the transcription against known strings (OCR accuracy
  verified: an invoice image transcribed all three lines correctly).
