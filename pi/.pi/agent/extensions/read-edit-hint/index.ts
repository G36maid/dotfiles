/**
 * read-edit-hint — a pi coding agent extension.
 *
 * Why it exists. pi's bash tool can read and write any file, so nothing stops
 * the model from drifting into `cat` for reads and python one-liners (or
 * heredoc scripts) for edits — the dedicated `read`/`edit` tools are mentioned
 * once in the system prompt, where the instruction decays over a long session.
 * This is the same "prompt rules decay, enforce at the tool boundary" gap that
 * nested-agents-md fills for instruction files: pi offers no native nudge for
 * tool substitution, so this extension adds one.
 *
 * What it does. When a bash command involves `cat` or `python`, prepend one
 * fixed line to the tool result so the model sees it:
 *
 *   hint: If you are reading, must use the `read` tool. If you are editing, must use the `edit` tool.
 *
 * Design decisions (deliberate, not lazy):
 *
 *   - Naive trigger. `\bcat\b|\bpython3?\b` with no context analysis. A
 *     smarter classifier was prototyped first (pipe/remote/scratch guards,
 *     python payload parsing) and measured against ~14k real commands; the
 *     naive gate kept ~90% of its value at a fraction of the failure surface,
 *     so the classifier was cut. Documented deviation from that prototype:
 *     piped reads (`cat f | wc -l`), remote ssh, and /tmp scratch writes are
 *     also nudged here — the message is conditional, so a nudge on a
 *     non-violation is one wasted line, not wrong guidance.
 *   - Conditional message. The model knows its own intent, so the line routes
 *     itself ("if you are reading … if you are editing …") instead of the
 *     extension guessing. Wording is the owner's, kept verbatim.
 *   - Warn-only. The command always runs and its output is preserved after
 *     the reminder; the extension never blocks or rewrites.
 *
 * Guards (each one line, each earns its keep):
 *   - `isError` results are skipped — the model already got an error.
 *   - Nested calls (`parentToolCallId`) are skipped — those results feed a
 *     script, not the model, and a reminder would corrupt the script's input.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

/** Bash commands mentioning either word get the reminder. `python3?` covers `python`, `python3`, `python3.x`; `\b` keeps `concat`/`category` out. */
const TRIGGER = /\bcat\b|\bpython3?\b/;

/** The reminder. Wording is the owner's; conditional so the model self-routes. */
const MESSAGE =
	"hint: If you are reading, must use the `read` tool. If you are editing, must use the `edit` tool.";

/** Exported for tests: does this tool input deserve the reminder? */
export function shouldHint(command: unknown): boolean {
	return typeof command === "string" && TRIGGER.test(command);
}

/** Exported for tests. */
export { MESSAGE, TRIGGER };

export default function readEditHint(pi: ExtensionAPI) {
	pi.on("tool_result", async (event) => {
		// only nudge real, successful bash calls surfaced to the model
		if (event.toolName !== "bash" || event.isError) return undefined;
		if ((event as { parentToolCallId?: string }).parentToolCallId) return undefined;
		const command = (event.input as Record<string, unknown> | undefined)?.command;
		if (!shouldHint(command)) return undefined;

		const reminder: { type: "text"; text: string } = { type: "text", text: MESSAGE };
		return {
			content: [reminder, ...event.content],
			...(event.structuredContent !== undefined ? { structuredContent: event.structuredContent } : {}),
		};
	});
}
