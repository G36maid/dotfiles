/**
 * Tool bridges for github.com/G36maid/pi-interactive-subagents: that fork
 * spawns sandboxed subagents with `--no-extensions -e <ext>` and resolves
 * whitelisted tool names through its runtime registry
 * (globalThis.__pi_interactive_subagents.registerToolExtension, see its
 * pi-extension/subagents/index.ts), but its built-in path table only knows
 * legacy ~/.pi/agent/extensions/ paths. This shim registers the npm-package
 * tools (pi-web-access, pi-mcp-adapter) onto that hook instead; safe_bash is
 * fork-provided and needs no entry here.
 *
 * MCP is universal: every enabled server in mcp.json becomes `mcp__<server>`
 * (sanitized like the adapter's namespaceServerPart) plus the `mcp` gateway,
 * so adding a server needs no edit here. directTools:true servers register
 * native tool names instead — whitelist those explicitly. The registry is
 * per-process, so grandchild spawns (worker → librarian) get an empty map
 * and silently drop bridged tools.
 *
 * Idempotent: safe to register on module load and again on session_start.
 */
import { existsSync, readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

function agentDir(): string {
	return process.env.PI_CODING_AGENT_DIR ?? join(homedir(), ".pi", "agent");
}

// Mirrors pi-mcp-adapter namespaceServerPart (mcp-references.ts): dashes become
// underscores; names that still aren't [A-Za-z0-9_]+ fall back to _mcpns_ hex
// encoding.
function namespaceServerPart(serverName: string): string {
	const normalized = serverName.replace(/-/g, "_");
	if (normalized === "" || (/^[A-Za-z0-9_]+$/.test(normalized) && !normalized.startsWith("_mcpns_"))) {
		return normalized;
	}
	const codePoints = Array.from(normalized, (char) => char.codePointAt(0)!.toString(16)).join("_");
	return `_mcpns_${codePoints}`;
}

function readMcpServers(): string[] {
	try {
		const raw = JSON.parse(readFileSync(join(agentDir(), "mcp.json"), "utf8"));
		const servers = raw?.mcpServers;
		if (!servers || typeof servers !== "object") return [];
		return Object.entries(servers)
			.filter(([, entry]) => !!entry && typeof entry === "object" && (entry as any).enabled !== false)
			.map(([name]) => name);
	} catch {
		return [];
	}
}

function computeBridges(): Record<string, string> {
	const nm = join(homedir(), ".pi", "agent", "npm", "node_modules");
	const bridges: Record<string, string> = {
		web_search: join(nm, "pi-web-access", "index.ts"),
		web_fetch: join(nm, "pi-web-access", "index.ts"), // legacy name; current package registers fetch_content
		fetch_content: join(nm, "pi-web-access", "index.ts"),
		get_search_content: join(nm, "pi-web-access", "index.ts"),
		source_check: join(nm, "pi-web-access", "index.ts"),
	};
	const adapter = join(nm, "pi-mcp-adapter", "index.ts");
	if (existsSync(adapter)) {
		bridges["mcp"] = adapter; // gateway meta-tool
		for (const server of readMcpServers()) {
			bridges[`mcp__${namespaceServerPart(server)}`] = adapter;
		}
	}
	return bridges;
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
