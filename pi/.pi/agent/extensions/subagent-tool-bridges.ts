/**
 * Tool bridges for github.com/G36maid/pi-interactive-subagents: that fork
 * spawns sandboxed subagents with `--no-extensions -e <ext>` and resolves
 * whitelisted tool names through its runtime registry
 * (globalThis.__pi_interactive_subagents.registerToolExtension, see its
 * pi-extension/subagents/index.ts), but its built-in path table only knows
 * legacy ~/.pi/agent/extensions/ paths. This shim registers the npm-package
 * tools (pi-web-access) onto that hook instead; safe_bash is fork-provided
 * and needs no entry here.
 *
 * MCP needs no bridge since pi 0.99 (native support): codemode /
 * tool_search are built-in extensions the fork re-enables itself via
 * `-e builtin:mcp -e builtin:codemode -e builtin:tool-search` whenever an
 * agent's tool allowlist mentions mcp / codemode / tool_search.
 *
 * Idempotent: safe to register on module load and again on session_start.
 */
import { existsSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

function computeBridges(): Record<string, string> {
	const nm = join(homedir(), ".pi", "agent", "npm", "node_modules");
	return {
		web_search: join(nm, "pi-web-access", "index.ts"),
		web_fetch: join(nm, "pi-web-access", "index.ts"), // legacy name; current package registers fetch_content
		fetch_content: join(nm, "pi-web-access", "index.ts"),
		get_search_content: join(nm, "pi-web-access", "index.ts"),
		source_check: join(nm, "pi-web-access", "index.ts"),
	};
}

function bridge(): void {
	const hook = (globalThis as any).__pi_interactive_subagents as
		| { registerToolExtension(name: string, path: string): void }
		| undefined;
	if (!hook) return;
	for (const [name, path] of Object.entries(computeBridges())) {
		if (existsSync(path)) {
			try {
				hook.registerToolExtension(name, path);
			} catch {
				// Already registered with a different path — leave the existing entry.
			}
		}
	}
}

bridge(); // module load: covers loading after the fork extension

export default function (pi: any) {
	bridge(); // covers loading before the fork extension
	pi.on?.("session_start", bridge);
}
