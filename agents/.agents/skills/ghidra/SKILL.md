---
name: ghidra
description: MUST USE for reverse engineering, binary analysis, decompilation, disassembly, and malware analysis tasks. Drives a running Ghidra instance via its MCP server (v7.0.0) — decompile, rename/type/comment functions, memory, xrefs, debugger, P-code emulation.
---

# Ghidra MCP

Talks to a **running Ghidra instance** (plugin on `127.0.0.1:8089`) — start Ghidra first. Rebuild/redeploy after updating `~/Code/AI/ghidra-mcp`: `uv run python -m tools.setup deploy --ghidra-path /opt/ghidra`.

Only ~75 of 205 tools are loaded by default. Discover what exists, then load groups on demand — new tools appear immediately:

- `mcp__ghidra__search_tools` / `list_tool_groups` — discovery
- `load_tool_group {group}` — e.g. `analysis`, `datatype`, `debugger`, `emulation`, `malware`, `xref`, `server`, `project`; `unload_tool_group` to trim
- Multiple open programs: `list_instances` / `connect_instance` / `switch_program`
- Debugger tools require a CodeBrowser with the Debugger view open

Workflow conventions: `~/Code/AI/ghidra-mcp/docs/prompts/` (start with `QUICK_START_PROMPT.md`, `TOOL_USAGE_GUIDE.md`).
