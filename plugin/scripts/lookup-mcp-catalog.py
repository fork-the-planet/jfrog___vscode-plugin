#!/usr/bin/env python3
"""Look up an MCP in the JFrog AI Catalog.

Usage: lookup-mcp-catalog.py <SERVER_ID> <PROJECT> <MCP_SEARCH>
Outputs one line:
  FOUND|<packageName>|<envVar1=description>,<envVar2=description>
  NOT_FOUND|<available names>
  ERROR|<message>
"""

import json
import os
import ssl
import sys
import urllib.request

if len(sys.argv) != 4:
    print("ERROR|Usage: lookup-mcp-catalog.py <SERVER_ID> <PROJECT> <MCP_SEARCH>")
    sys.exit(0)

SERVER_ID = sys.argv[1]
PROJECT = sys.argv[2]
MCP_SEARCH = sys.argv[3].lower()

conf_path = os.path.expanduser("~/.jfrog/jfrog-cli.conf.v6")
token = ""
url = ""
try:
    conf = json.load(open(conf_path))
    server = next((s for s in conf.get("servers", []) if s.get("serverId") == SERVER_ID), None)
    if server:
        token = server.get("accessToken", "")
        url = server.get("url", "").rstrip("/")
except Exception:
    pass
if not token or not url:
    token = token or os.environ.get("JFROG_ACCESS_TOKEN", "") or os.environ.get("JF_ACCESS_TOKEN", "")
    url = url or os.environ.get("JFROG_URL", "") or os.environ.get("JF_URL", "")
    if url:
        url = url.rstrip("/")
if not token or not url:
    print("ERROR|No credentials found. Set JFROG_ACCESS_TOKEN and JFROG_URL env vars, or run: jf c add " + SERVER_ID)
    sys.exit(0)

api = url + "/ml/core/api/v1/mcp-registry/allowed-registered-servers/" + PROJECT + "?pageSize=500"
req = urllib.request.Request(api, headers={"Authorization": "Bearer " + token})
try:
    resp = urllib.request.urlopen(req, context=ssl.create_default_context())
    data = json.loads(resp.read())
except Exception as e:
    print("ERROR|Catalog API failed: " + str(e))
    sys.exit(0)

names = []
for entry in data.get("registeredServers", []):
    spec = entry.get("mcpServer", {}).get("spec", {})
    pkg = spec.get("packageName", "")
    display = spec.get("displayName", "")
    names.append(pkg or display)
    if MCP_SEARCH and (MCP_SEARCH in pkg.lower() or MCP_SEARCH in display.lower()):
        st = spec.get("mcpServerType", {})
        local_env = st.get("local", {}).get("bootParams", {}).get("environmentVariables", [])
        required = []
        for e in local_env:
            if e.get("isRequired"):
                tag = "[secret]" if e.get("isSecret") else ""
                required.append(e["name"] + "=" + tag + e.get("description", ""))
        for ep in st.get("remote", {}).get("endpoints", []):
            for hdr in ep.get("headers", []):
                inp = hdr.get("mcpInput", {})
                det = inp.get("mcpInputDetails", {})
                if det.get("name") and not inp.get("defaultValue"):
                    tags = ["header"]
                    if det.get("isRequired"):
                        tags.append("required")
                    if det.get("isSecret"):
                        tags.append("secret")
                    label = "[" + ",".join(tags) + "] " + det.get("description", "")
                    required.append(det["name"] + "=" + label)
        print("FOUND|" + (pkg or display) + "|" + ",".join(required))
        sys.exit(0)
print("NOT_FOUND|" + ",".join(names))
