library(tidyverse)
library(arrow)

crashes <- read_parquet("../data/utah-crash-data-2020.parquet")
glimpse(crashes)


# Check date range, severity distribution, and geographic spread
# cat("Date range:\n")
range(crashes$CRASH_DATETIME, na.rm = TRUE)


# Severity distribution and county coverage
crashes |> count(CRASH_SEVERITY_ID, sort = TRUE)


crashes |>
  summarise(across(where(is.logical), mean, na.rm = TRUE)) |>
  pivot_longer(everything(), names_to = "flag", values_to = "rate") |>
  arrange(desc(rate))

# Crashes by county, sorted by count 

crashes |> 
  # group_by(COUNTY_NAME) |> 
  summarize(n = n(),by = COUNTY_NAME) |> 
  arrange(desc(n))


utah_county_subset = crashes |>  filter(COUNTY_NAME == "UTAH")

### Make a ggplot summarizes the number of all crashes by hour of the day and crash severity.
# Color by crash severity. log10 scale - preserve orginal number of counts in label with the transformations
ggplot(crashes, aes(x = hour(CRASH_DATETIME), fill = factor(CRASH_SEVERITY_ID))) +
  geom_bar(stat = "count") +
  labs(x = "Hour of Day", y = "Number of Crashes", fill = "Crash Severity") +
  theme_minimal(base_size = 16) + 
  scale_y_continuous(trans = "log10") + 
  scale_fill_viridis_d()

