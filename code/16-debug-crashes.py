# 16-debug-crashes.py
# Deck 06: Working in your editor (Debug and fix)
# Goal: a short crash analysis with several planted bugs. Run each cell in
# order. When you hit an error, ask Posit Assistant "what went wrong and how do
# I fix it?" instead of fixing it yourself. There is more than one bug.

# %% Import packages and load data
import polars as pl
from plotnine import aes, geom_col, ggplot, labs
from pyhere import here

crashes = pl.read_parquet(here("data/utah-crash-data-2020.parquet"))

# %% Which counties have the most crashes?
crashes["COUNTY"].value_counts(sort=True)

# %% Convert milepoints from miles to kilometers
crashes.select(
    "CRASH_ID",
    "MILEPOINT",
    milepoint_km=pl.col("MILEPOINT") * 1.60934,
)

# %% How do crashes vary by hour of day?
crashes_by_hour = (
    crashes.with_columns(hour=pl.col("CRASH_DATETIME").dt.hour())
    .group_by("hour")
    .agg(pl.len().alias("n"))
    .sort("hour")
)

(
    ggplot(crash_by_hour, aes(x="hour", y="n"))
    + geom_col()
    + labs(x="Hour of day", y="Number of crashes")
)
