/**
 * Tests for the trigger regex and the tool_result hook. The hook is exercised
 * through a minimal pi harness (handler registry + event replay) so the
 * content-patch contract is verified end to end: reminder prepended, original
 * output preserved, skip-guards respected.
 */
import { describe, expect, it } from "vitest";
import readEditHint, { MESSAGE, shouldHint } from "../index.js";

// -- harness ----------------------------------------------------------------

interface Handler {
	(event: unknown, ctx: unknown): Promise<unknown>;
}

function makeHarness() {
	const handlers = new Map<string, Handler[]>();
	const pi = {
		on(event: string, handler: Handler) {
			const list = handlers.get(event) ?? [];
			list.push(handler);
			handlers.set(event, list);
			return () => {};
		},
	};
	async function runToolResult(event: Record<string, unknown>): Promise<Record<string, unknown>> {
		let out: Record<string, unknown> = event;
		for (const handler of handlers.get("tool_result") ?? []) {
			out = ((await handler(out, {})) as Record<string, unknown>) ?? out;
		}
		return out;
	}
	return { pi, runToolResult };
}

function bashResult(command: string, overrides: Record<string, unknown> = {}) {
	return {
		type: "tool_result",
		toolCallId: "call_1",
		toolName: "bash",
		input: { command },
		content: [{ type: "text", text: "original output" }],
		isError: false,
		...overrides,
	};
}

// -- trigger ----------------------------------------------------------------

describe("shouldHint", () => {
	it("fires on cat", () => {
		expect(shouldHint("cat /etc/hostname")).toBe(true);
		expect(shouldHint("echo hi | cat")).toBe(true);
	});

	it("fires on python in any common spelling", () => {
		expect(shouldHint("python script.py")).toBe(true);
		expect(shouldHint("python3 -c 'print(1)'")).toBe(true);
		expect(shouldHint("python3.11 -m venv .venv")).toBe(true);
		expect(shouldHint("/usr/bin/python -V")).toBe(true);
	});

	it("does not fire on word fragments or other tools", () => {
		expect(shouldHint("echo category")).toBe(false);
		expect(shouldHint("concat a b")).toBe(false);
		expect(shouldHint("npm run build")).toBe(false);
	});

	it("non-string input is safe", () => {
		expect(shouldHint(undefined)).toBe(false);
	});
});

// -- hook -------------------------------------------------------------------

describe("tool_result hook", () => {
	it("prepends the reminder and preserves the original output", async () => {
		const { pi, runToolResult } = makeHarness();
		readEditHint(pi as never);
		const patched = await runToolResult(bashResult("cat /etc/hostname"));
		const content = patched.content as Array<{ type: string; text: string }>;
		expect(content).toHaveLength(2);
		expect(content[0].text).toBe(MESSAGE);
		expect(content[1].text).toBe("original output");
	});

	it("leaves non-triggering commands untouched", async () => {
		const { pi, runToolResult } = makeHarness();
		readEditHint(pi as never);
		const original = bashResult("npm run build");
		const result = await runToolResult(original);
		expect(result).toEqual(original);
	});

	it("skips failed commands", async () => {
		const { pi, runToolResult } = makeHarness();
		readEditHint(pi as never);
		const original = bashResult("cat missing.txt", { isError: true });
		const result = await runToolResult(original);
		expect(result).toEqual(original);
	});

	it("skips nested calls (results feed a script, not the model)", async () => {
		const { pi, runToolResult } = makeHarness();
		readEditHint(pi as never);
		const original = bashResult("cat x", { parentToolCallId: "call_0" });
		const result = await runToolResult(original);
		expect(result).toEqual(original);
	});

	it("skips non-bash tools", async () => {
		const { pi, runToolResult } = makeHarness();
		readEditHint(pi as never);
		const original = { type: "tool_result", toolName: "read", input: { path: "x" }, content: [], isError: false };
		const result = await runToolResult(original);
		expect(result).toEqual(original);
	});
});
