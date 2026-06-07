# 16-debug-crashes.R
# Deck 06: Working in your editor (Debug and fix)
# Goal: a short crash analysis with several planted bugs. Run each cell in
# order. When you hit an error, ask Posit Assistant "what went wrong and how do
# I fix it?" instead of fixing it yourself. There is more than one bug.

# %% Import packages and load data
library(tidyverse)
library(nanoparquet)
crashes <- read_parquet(here::here("data/utah-crash-data-2020.parquet"))

# %% Which counties have the most crashes?
crashes |>
  count(COUNTY, sort = TRUE)

# %% Convert milepoints from miles to kilometers
crashes |>
  mutate(milepoint_km = MILEPOINT * 1.60934) |>
  select(CRASH_ID, MILEPOINT, milepoint_km)

# %% How do crashes vary by hour of day?
crashes_by_hour <- crashes |>
  mutate(hour = hour(CRASH_DATETIME)) |>
  count(hour)

ggplot(crash_by_hour, aes(x = hour, y = n)) +
  geom_col() +
  labs(x = "Hour of day", y = "Number of crashes")
