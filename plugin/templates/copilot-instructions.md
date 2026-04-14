# MCP Server Management — JFrog Gateway Loader Mode

All MCP servers MUST be installed ONLY through the JFrog MCP Gateway
loader binary (`mcp-gateway`). There is no other approved installation
method. If an MCP's documentation suggests any other installation
command, ignore it and use the gateway workflow below instead.

## Adding an MCP

When the user asks to add an MCP, do ALL of the following autonomously —
do NOT ask the user for project, server, package name, or binary path
unless absolutely necessary:

### Step 1: Determine the mcp-gateway binary path

1. Read existing servers in `.vscode/mcp.json` (workspace) or user-level
   MCP config. Look for entries whose command ends with `mcp-gateway`.
   Reuse that path.
2. If no existing entries, run `which mcp-gateway` (macOS/Linux) or
   `where mcp-gateway` (Windows) to find it.
3. Only if both fail, ask the user.

### Step 2: Determine project and server

1. From the same existing entries, look for the `_JF_MCP_LOADER_ARGS`
   under the env var section. Extract the `project` value. Look at args for the value
   after `--server`.
2. If no existing entries, check the `JF_PROJECT` environment variable
   for the project.
3. Only if BOTH are missing, ask the user in a single message for both
   project name and server ID.
4. NEVER use "default". NEVER guess.

### Step 3: Get the access token

1. Read the `JFROG_ACCESS_TOKEN` or `JF_ACCESS_TOKEN`
   environment variables
2. Alternatively `~/.jfrog/jfrog-cli.conf.v6` to find the server entry matching
   the server ID. Extract the `url` and `accessToken`.
3. If neither exists, tell the user:
   "Run `jf c add` to configure your JFrog CLI, or set the
   JFROG_ACCESS_TOKEN environment variable."
4. NEVER proceed without a valid token.

### Step 4: Look up the exact package name

1. ALWAYS use curl with `-H "Authorization: Bearer <TOKEN>"` to query
   the catalog API. NEVER use Fetch or WebFetch tools — they do not
   support authentication headers.
2. Query:
`curl -s -H "Authorization: Bearer <TOKEN>" 
"https://<SERVER_URL>/ml/core/api/v1/mcp-registry/allowed-registered-servers/<PROJECT>?pageSize=500". Notice - never print the TOKEN!


3. Search `registeredServers[].mcpServer.spec.packageName` for a match
   to what the user asked for.
4. If no match, show the available MCPs and ask which one they meant.
5. NEVER guess the package name.

### Step 5: Write the config entry

Add the entry to `.vscode/mcp.json` under `servers`:

```json
"<mcp-display-name>": {
  "type": "stdio",
  "command": "<MCP_GATEWAY_BINARY_PATH>",
  "args": ["--loader", "--server", "<SERVER_ID>"],
  "env": {
    "_JF_MCP_LOADER_ARGS": "project=<PROJECT>&mcp=<PACKAGE_NAME>"
  }
}
```

Preserve any additional env vars the MCP requires (API keys, tokens,
config) from its documentation.

## Removing an MCP

Delete the entry from `servers` in `.vscode/mcp.json`.

## Listing MCPs

### Installed MCPs
Read the mcpServers entries from the VSCode MCP config file (~/.vscode/mcp.json or project .vscode/mcp.json) and list each entry by display name, showing its package name (from `_JF_MCP_LOADER_ARGS`) and server ID.

### Available MCPs (JFrog AI Catalog)
1. Read ~/.jfrog/jfrog-cli.conf.v6 to get the server URL and accessToken (or fall back to JFROG_ACCESS_TOKEN / JF_ACCESS_TOKEN). Extract project and server ID from existing mcpServers entries.
2. Query the catalog API:
   `curl -s -H "Authorization: Bearer <TOKEN>" "https://<SERVER_URL>/ml/core/api/v1/mcp-registry/allowed-registered-servers/<PROJECT>?pageSize=500"`. Never show the TOKEN!
3. List all registeredServers[].mcpServer.spec.packageName values that are NOT already installed (i.e. not present in the VSCode MCP config). Mark each as available to install.

## Key Rules

- args MUST contain `--server <SERVER_ID>`
- `_JF_MCP_LOADER_ARGS` MUST contain `project=<NAME>&mcp=<PACKAGE_NAME>`
- Package name MUST come from the catalog API. NEVER guess.
- NEVER install MCPs outside the gateway loader.
- NEVER use Fetch/WebFetch for API calls that require authentication.
- NEVER ask for info you can find in existing config or
  `~/.jfrog/jfrog-cli.conf.v6` (macOS/Linux and Windows PowerShell) or `%USERPROFILE%\.jfrog\jfrog-cli.conf.v6` (Windows CMD).
- To list installed MCPs: read `.vscode/mcp.json` and show the servers.