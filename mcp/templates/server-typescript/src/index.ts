#!/usr/bin/env node
// Minimal stdio MCP server. One tool: `hello`.
// IMPORTANT: never write to stdout (console.log) — it corrupts the JSON-RPC
// stream on stdin/stdout. Use console.error for diagnostics.

import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

const server = new McpServer({
  name: "mcp-server-demo-ts",
  version: "0.1.0",
});

server.registerTool(
  "hello",
  {
    title: "Hello",
    description: "Greets the given name.",
    inputSchema: { name: z.string().min(1).describe("Who to greet") },
  },
  async ({ name }) => ({
    content: [{ type: "text", text: `Hello, ${name}!` }],
  }),
);

async function main(): Promise<void> {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("[mcp-server-demo-ts] connected on stdio");
}

main().catch((err) => {
  console.error("[mcp-server-demo-ts] fatal:", err);
  process.exit(1);
});
