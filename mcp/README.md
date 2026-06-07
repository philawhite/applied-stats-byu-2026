# Utah crash MCP server

A tiny local [MCP](https://modelcontextprotocol.io/) server that gives Posit
Assistant two things it cannot reliably do on its own with this dataset:

- `crash_codebook` — what the severity codes mean, that the coordinates are UTM
  (not latitude/longitude), and other quirks of the data
- `reproject` — convert a crash's `LONG_UTM_X` / `LAT_UTM_Y` (NAD83 UTM zone 12N)
  to latitude/longitude, so the assistant can map crashes correctly

## Running it

You need [`uv`](https://docs.astral.sh/uv/). The server is a single script with
its dependencies declared inline, so `uv` provisions Python, `mcp`, and `pyproj`
for you. No virtual environment or `pip install` needed, which makes this work
for R-only folks too.

```bash
uv run mcp/crash-server.py
```

The first run downloads the dependencies, so run it once before the workshop to
warm the cache.

## Wiring it into Posit Assistant

Add this to your project `.positai/settings.json` (run Posit Assistant from the
workshop repo so the relative path resolves):

```json
{
  "mcpServers": {
    "utah-crash": {
      "type": "local",
      "command": ["uv", "run", "mcp/crash-server.py"]
    }
  }
}
```

Restart Posit Assistant and confirm the `utah-crash` tools appear. Then ask
something that uses them, for example:

- *"What does crash severity 4 mean in this data?"* (uses `crash_codebook`)
- *"Plot the 10 deadliest crash locations on a map"* (uses `reproject`)
