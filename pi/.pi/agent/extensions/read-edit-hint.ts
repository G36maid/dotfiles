/**
 * read-edit-hint — a minimal pi coding agent extension.
 *
 * When a bash command involves `cat` or `python`, prepend one fixed line to
 * the tool result so the model sees it:
 *
 *   read-edit-hint: If you are reading, you must use the read tool.
 *   If you are editing, you must use the edit tool.
 *
 * The message is deliberately conditional: the model knows its own intent,
 * so it routes itself to the right tool. No command analysis beyond the
 * trigger regex, on purpose. A false trigger costs one line of tokens and
 * nothing else — the command still runs and its output is preserved.
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export const TRIGGER = /\bcat\b|\bpython3?\b/;

export const MESSAGE =
  "hint: If you are reading, must use the `read` tool. If you are editing, must use the `edit` tool.";

export function shouldHint(command: unknown): boolean {
  return typeof command === "string" && TRIGGER.test(command);
}

export default function (pi: ExtensionAPI) {
  pi.on("tool_result", async (event) => {
    // only nudge real, successful bash calls surfaced to the model
    if (event.toolName !== "bash" || event.isError) return undefined;
    if ((event as { parentToolCallId?: string }).parentToolCallId) return undefined; // nested call: result feeds a script
    const command = (event.input as Record<string, unknown> | undefined)?.command;
    if (!shouldHint(command)) return undefined;

    const reminder: { type: "text"; text: string } = { type: "text", text: MESSAGE };
    return {
      content: [reminder, ...event.content],
      ...(event.structuredContent !== undefined ? { structuredContent: event.structuredContent } : {}),
    };
  });
}
