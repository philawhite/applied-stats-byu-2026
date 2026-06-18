# 15-debug-crashes.R
# Deck 06: Working in your editor (Debug and fix)
# Goal: a short crash analysis with several planted bugs. Run each cell in
# order. When you hit an error, ask Posit Assistant "what went wrong and how do
# I fix it?" instead of fixing it yourself. There is more than one bug.

# %% Import packages and load data
library(tidyverse)
library(lubridate)
library(nanoparquet)
crashes <- read_parquet(here::here("data/utah-crash-data-2020.parquet"))

# %% Prepare time variables for seasonal EDA
crashes_time <- crashes |>
  filter(!is.na(CRASH_DATETIME)) |>
  mutate(
    crash_date = as_date(CRASH_DATETIME),
    crash_year = year(CRASH_DATETIME),
    crash_month = month(CRASH_DATETIME, label = TRUE, abbr = TRUE),
    crash_week = floor_date(crash_date, unit = "week", week_start = 1),
    crash_weekday = wday(
      CRASH_DATETIME,
      label = TRUE,
      abbr = FALSE,
      week_start = 1
    ),
    crash_hour = hour(CRASH_DATETIME)
  )

crashes_time |>
  summarise(
    first_crash = min(CRASH_DATETIME),
    last_crash = max(CRASH_DATETIME),
    total_crashes = n()
  )

# %% Which counties have the most crashes?
crashes |>
  count(COUNTY_NAME, sort = TRUE)

# %% Convert milepoints from miles to kilometers
crashes |>
  mutate(milepoint_km = as.numeric(MILEPOINT) * 1.60934) |>
  select(CRASH_ID, MILEPOINT, milepoint_km)

# %% How do crashes vary by hour of day?
crashes_by_hour <- crashes_time |>
  count(crash_hour, name = "crashes") |>
  complete(crash_hour = 0:23, fill = list(crashes = 0))

ggplot(crashes_by_hour, aes(x = crash_hour, y = crashes)) +
  geom_col() +
  scale_x_continuous(breaks = seq(0, 23, by = 2)) +
  labs(x = "Hour of day", y = "Number of crashes") +
  theme_minimal()

# %% Daily seasonality: raw daily counts and a 7-day moving average
crash_date_range <- range(crashes_time$crash_date, na.rm = TRUE)

crashes_by_day <- crashes_time |>
  count(crash_date, name = "crashes") |>
  complete(
    crash_date = seq.Date(crash_date_range[1], crash_date_range[2], by = "day"),
    fill = list(crashes = 0)
  ) |>
  arrange(crash_date) |>
  mutate(
    crashes_7_day_avg = as.numeric(
      stats::filter(crashes, rep(1 / 7, 7), sides = 2)
    )
  )

crashes_by_day |>
  arrange(desc(crashes)) |>
  slice_head(n = 10)

ggplot(crashes_by_day, aes(x = crash_date, y = crashes)) +
  geom_line(alpha = 0.35, linewidth = 0.3) +
  geom_line(
    aes(y = crashes_7_day_avg),
    color = "#0072B2",
    linewidth = 0.8,
    na.rm = TRUE
  ) +
  labs(
    x = "Crash date",
    y = "Number of crashes",
    title = "Daily crashes with 7-day moving average"
  ) +
  theme_minimal()

# %% Weekly seasonality: average crashes by weekday
crashes_by_weekday <- crashes_by_day |>
  mutate(
    crash_weekday = wday(
      crash_date,
      label = TRUE,
      abbr = FALSE,
      week_start = 1
    )
  ) |>
  group_by(crash_weekday) |>
  summarise(
    days = n(),
    mean_daily_crashes = mean(crashes),
    median_daily_crashes = median(crashes),
    .groups = "drop"
  )

crashes_by_weekday

ggplot(crashes_by_weekday, aes(x = crash_weekday, y = mean_daily_crashes)) +
  geom_col(fill = "#009E73") +
  labs(
    x = "Day of week",
    y = "Average crashes per day",
    title = "Average daily crashes by weekday"
  ) +
  theme_minimal()

# %% Weekly trend: total crashes by week
crash_week_range <- range(crashes_time$crash_week, na.rm = TRUE)

crashes_by_week <- crashes_time |>
  count(crash_week, name = "crashes") |>
  complete(
    crash_week = seq.Date(crash_week_range[1], crash_week_range[2], by = "week"),
    fill = list(crashes = 0)
  ) |>
  filter(
    crash_week >= crash_date_range[1],
    crash_week + days(6) <= crash_date_range[2]
  ) |>
  arrange(crash_week)

crashes_by_week |>
  arrange(desc(crashes)) |>
  slice_head(n = 10)

ggplot(crashes_by_week, aes(x = crash_week, y = crashes)) +
  geom_line(color = "#D55E00", linewidth = 0.6) +
  labs(
    x = "Week starting",
    y = "Number of crashes",
    title = "Weekly crash totals"
  ) +
  theme_minimal()

# %% Daily-by-weekly seasonality: hour of day by weekday
crashes_by_weekday_hour <- crashes_time |>
  count(crash_weekday, crash_hour, name = "crashes") |>
  complete(
    crash_weekday,
    crash_hour = 0:23,
    fill = list(crashes = 0)
  )

ggplot(
  crashes_by_weekday_hour,
  aes(x = crash_hour, y = crash_weekday, fill = crashes)
) +
  geom_tile() +
  scale_x_continuous(breaks = seq(0, 23, by = 3)) +
  scale_fill_viridis_c() +
  labs(
    x = "Hour of day",
    y = "Day of week",
    fill = "Crashes",
    title = "Crash volume by weekday and hour"
  ) +
  theme_minimal()

# %% Annual seasonality: monthly crash rates by year
crashes_by_month <- crashes_by_day |>
  mutate(
    crash_year = year(crash_date),
    crash_month = month(crash_date, label = TRUE, abbr = TRUE)
  ) |>
  group_by(crash_year, crash_month) |>
  summarise(
    days = n(),
    crashes = sum(crashes),
    crashes_per_day = crashes / days,
    .groups = "drop"
  )

crashes_by_month |>
  group_by(crash_month) |>
  summarise(
    mean_daily_crashes = mean(crashes_per_day),
    .groups = "drop"
  ) |>
  arrange(desc(mean_daily_crashes))

ggplot(
  crashes_by_month,
  aes(
    x = crash_month,
    y = crashes_per_day,
    color = factor(crash_year),
    group = crash_year
  )
) +
  geom_line(linewidth = 0.7) +
  geom_point(size = 1.8) +
  labs(
    x = "Month",
    y = "Crashes per day",
    color = "Year",
    title = "Monthly crash seasonality by year"
  ) +
  theme_minimal()

# %% Annual seasonality: average crash pattern across the calendar year
crashes_by_calendar_day <- crashes_by_day |>
  mutate(
    season_date = make_date(2021, month(crash_date), mday(crash_date))
  ) |>
  filter(!is.na(season_date)) |>
  group_by(season_date) |>
  summarise(
    mean_daily_crashes = mean(crashes),
    .groups = "drop"
  ) |>
  arrange(season_date) |>
  mutate(
    mean_14_day_avg = as.numeric(
      stats::filter(mean_daily_crashes, rep(1 / 14, 14), sides = 2)
    )
  )

ggplot(crashes_by_calendar_day, aes(x = season_date, y = mean_daily_crashes)) +
  geom_line(alpha = 0.35, linewidth = 0.3) +
  geom_line(
    aes(y = mean_14_day_avg),
    color = "#CC79A7",
    linewidth = 0.8,
    na.rm = TRUE
  ) +
  scale_x_date(date_breaks = "1 month", date_labels = "%b") +
  labs(
    x = "Calendar date",
    y = "Average crashes per day",
    title = "Average annual crash seasonality"
  ) +
  theme_minimal()

# %% Annual trend: total crashes by year
crashes_by_year <- crashes_time |>
  count(crash_year, name = "crashes")

crashes_by_year

ggplot(crashes_by_year, aes(x = factor(crash_year), y = crashes)) +
  geom_col(fill = "#56B4E9") +
  labs(
    x = "Year",
    y = "Number of crashes",
    title = "Total crashes by year"
  ) +
  theme_minimal()
