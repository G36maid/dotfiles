/**
 * Tool-provider bridges for the interactive-subagents fork.
 *
 * The fork launches subagent children with `--no-extensions` plus `-e <path>`
 * for each extension that backs a tool in the agent's `tools:` allowlist. Its
 * built-in path table only knows the legacy `~/.pi/agent/extensions/` layout;
 * tools provided by npm-installed packages (pi-web-access, pi-mcp-adapter)
 * must be registered here so children can be granted them.
 *
 * Limitation: the fork's registration map is per-process. This file loads in
 * top-level sessions (global extension discovery), so top-level spawns resolve
 * these tools. A subagent that itself spawns children (worker → librarian)
 * resolves against its own map, which nothing populates — those grandchildren
 * silently fall back to their remaining tools.
 *
 * Idempotent: safe to register on module load and again on session_start.
 */
import { existsSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

function bridge(): void {
	const hook = (globalThis as any).__pi_interactive_subagents as
		| { registerToolExtension(name: string, path: string): void }
		| undefined;
	if (!hook) return;

	const nm = join(homedir(), ".pi", "agent", "npm", "node_modules");
	const webAccess = join(nm, "pi-web-access", "index.ts");
	const bridges: Record<string, string> = {
		web_search: webAccess,
		web_fetch: webAccess, // legacy name; current package registers fetch_content
		fetch_content: webAccess,
		get_search_content: webAccess,
		source_check: webAccess,
		mcp__deepwiki: join(nm, "pi-mcp-adapter", "index.ts"),
		mcp__context7: join(nm, "pi-mcp-adapter", "index.ts"),
		mcp__grep_app: join(nm, "pi-mcp-adapter", "index.ts"),
	};
	for (const [name, path] of Object.entries(bridges)) {
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
