# server-typescript

Minimal TypeScript MCP server starter. One tool (`hello`) over stdio.

## Layout

```
server-typescript/
  package.json
  tsconfig.json
  src/index.ts   # server + tool registration
```

## Build and run

```bash
cd server-typescript
npm install
npm run build           # emits build/index.js
node ./build/index.js   # speaks MCP over stdio; will appear to hang — it is waiting for a client
```

A bare `node ./build/index.js` is not interactive. MCP servers only do useful
work when a client (Claude Code, Claude Desktop, an inspector, etc.) connects
to them over stdio.

## Register with Claude Code

From the directory containing `build/index.js` (or use an absolute path):

```bash
claude mcp add demo-ts -- node /absolute/path/to/server-typescript/build/index.js
```

Then in Claude Code, call the `hello` tool with `{ "name": "world" }`.

To remove:

```bash
claude mcp remove demo-ts
```

## Pitfalls

- **stdio is sacred.** The JSON-RPC protocol runs over stdin/stdout. Any stray
  `console.log`, `print`, unhandled promise rejection written to stdout, or
  dependency that prints a banner on import will corrupt the framing and the
  client will show the server as disconnected. Log with `console.error` only.
- **Build before registering.** `claude mcp add` stores the command, it doesn't
  build anything for you. Re-run `npm run build` after edits.
- **ESM + `.js` imports.** Under `"type": "module"` and `Node16` resolution,
  relative imports from TypeScript source need the compiled `.js` extension
  (e.g. `import "./util.js"`, not `"./util"`). The SDK paths above already use this.
- **Node 20+** is required by the current SDK.
- **Client restart.** After changing the server binary, restart the MCP client
  (or toggle the server off/on) to pick up changes — Claude Code caches the
  spawned process.
