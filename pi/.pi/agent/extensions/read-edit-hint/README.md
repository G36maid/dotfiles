# read-edit-hint

A minimal pi coding agent extension. When a bash command involves `cat` or
`python`, the extension prepends one fixed line to the tool result so the
model sees it:

```
read-edit-hint: Do not read or edit files with `cat` or `python`. Use the `read` tool to read and the `edit` tool to edit.
```

The message states the rule directly, but routing is still the model's: it
knows whether it is reading or editing and picks the tool. See `index.ts`
for the full design record (why the trigger is naive, why the message is
a direct rule, why the extension never blocks).

## Develop

```
npm install
npm run typecheck
npm test
```
