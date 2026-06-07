# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "mcp",
#   "pyproj",
# ]
# ///
# crash-server.py
# Deck 07: Steering and extending (Tools via MCP)
# A small local MCP server for the Utah crash data. Run it with uv, which reads
# the dependency block above and provisions Python and the dependencies for you:
#
#   uv run mcp/crash-server.py
#
# Then point Posit Assistant at it (see mcp/README.md for the config snippet).

from pyproj import Transformer
from mcp.server.fastmcp import FastMCP

# Utah crash coordinates are NAD83 UTM zone 12N (EPSG:26912), not lat/long.
_utm_to_latlon = Transformer.from_crs("EPSG:26912", "EPSG:4326", always_xy=True)

mcp = FastMCP("utah-crash")


@mcp.tool()
def crash_codebook() -> str:
    """Return the codebook for the Utah crash dataset: how to read the columns."""
    return (
        "Utah crash data, 2016-2019, one row per crash.\n\n"
        "CRASH_SEVERITY_ID (1-5, ordinal):\n"
        "  1 = no injury (property damage only)\n"
        "  2 = possible injury\n"
        "  3 = suspected minor injury\n"
        "  4 = suspected serious injury\n"
        "  5 = fatal\n\n"
        "Coordinates: LONG_UTM_X / LAT_UTM_Y are NAD83 UTM zone 12N (EPSG:26912),\n"
        "NOT latitude/longitude. Use the reproject tool to convert them.\n\n"
        "ROUTE, MILEPOINT, and the coordinates are stored as strings.\n"
        "Boolean risk-factor flags include DUI, DISTRACTED_DRIVING, NIGHT_DARK_CONDITION,\n"
        "TEENAGE_DRIVER_INVOLVED, INTERSECTION_RELATED, PEDESTRIAN_INVOLVED, and more."
    )


@mcp.tool()
def reproject(utm_x: float, utm_y: float) -> dict:
    """Convert a Utah crash UTM coordinate (LONG_UTM_X, LAT_UTM_Y) to latitude/longitude."""
    lon, lat = _utm_to_latlon.transform(utm_x, utm_y)
    return {"lat": lat, "lon": lon}


if __name__ == "__main__":
    mcp.run()
