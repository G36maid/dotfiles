# read-edit-hint

A minimal pi coding agent extension. When a bash command involves `cat` or
`python`, the extension prepends one fixed line to the tool result so the
model sees it:

```
hint: If you are reading, must use the `read` tool. If you are editing, must use the `edit` tool.
```

The message is deliberately conditional — the model knows whether it is
reading or editing, so it routes itself. See `index.ts` for the full design
record (why the trigger is naive, why the message is conditional, why the
extension never blocks).

## Develop

```
npm install
npm run typecheck
npm test
```
