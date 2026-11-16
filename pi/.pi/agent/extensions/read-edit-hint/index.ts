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
 *   read-edit-hint: Do not read or edit files with `cat` or `python`.
 *   Use the `read` tool to read and the `edit` tool to edit.
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
 *   - Direct rule, self-routed tools. The line states the rule outright
 *     ("do not read or edit files with `cat` or `python`") instead of a
 *     conditional, but routing is still the model's: it knows whether it is
 *     reading or editing and picks `read` or `edit` accordingly. Wording
 *     chosen with the owner.
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

/** The reminder. States the rule directly; the model still picks read vs edit by intent. */
const MESSAGE =
	"read-edit-hint: Do not read or edit files with `cat` or `python`. Use the `read` tool to read and the `edit` tool to edit.";

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
