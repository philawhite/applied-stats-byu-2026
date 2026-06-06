---
name: workshop-time-estimate
description: Estimate how much time the current Quarto reveal.js workshop content will take. Sums all `{{< countdown >}}` shortcodes for activity time, counts non-exercise slides, and reports lower / upper bounds with a comparison against the schedule in index.qmd. Trigger phrases include "estimate time", "how long is the workshop", "time budget", "do I have enough content", "fill the schedule".
---

# Workshop time estimate

Use this skill when the user asks how much time the current workshop content will take, or whether they have enough material to fill a session/day.

## Assumptions about the project layout

This skill assumes the conventions used in this repo:

- Slide decks live at `slides/0*.qmd` (numbered prefixes).
- Activity slides use `## Your turn` as their heading and contain a `{{< countdown minutes=N >}}` shortcode that defines the hands-on time.
- Section divider slides start with `# Heading`. Content slides start with `## Heading`.
- The workshop schedule, if present, lives in a Markdown table inside `index.qmd` with rows shaped like `| 09:00 - 10:10 | ... |`.

If any of these conventions are not present, ask the user before running so you don't produce bogus numbers.

## Procedure

1. Run the data-collection script below. Capture per-deck and total numbers.
2. Estimate the content time using these defaults (state them in the output so the user can override):
   - Non-exercise slides: **1 min/slide** for the lower bound, **2 min/slide** for the upper bound.
   - Demo slides (`## Demo` / `## Demos`): **5 min** for the lower bound, **8 min** for the upper bound, each. Demos are counted at this rate *instead of* as 1-2 min content slides (not on top of), so the script excludes them from the content-slide count. Note a single `## Demos` slide can bundle several demos; if it runs more than one demo live, bump it manually.
   - Activity time: the sum of all `countdown minutes=N` values.

   So per deck: **low = countdowns + (non-exercise slides x 1) + (demos x 5)** and **high = countdowns + (non-exercise slides x 2) + (demos x 8)**.
3. If `index.qmd` has a schedule table, parse the time ranges per day and compute the total minutes available per day and across the workshop. Otherwise, ask the user for the session lengths.
4. Produce a per-deck table and an overall summary with the lower / upper bounds and a comparison against the schedule.
5. End with one sentence on whether content fits, is short, or runs over, and which deck(s) are most likely to overflow or underflow.

## Data-collection script

Run this from the project root:

```bash
echo "=== Countdowns per deck ==="
total_countdown=0
for f in slides/0*.qmd; do
  cd_total=$(grep -oE "countdown minutes=[0-9]+" "$f" | grep -oE "[0-9]+" | paste -sd+ - | bc)
  cd_total=${cd_total:-0}
  echo "$f: $cd_total min"
  total_countdown=$((total_countdown + cd_total))
done
echo "Total countdown minutes: $total_countdown"

echo ""
echo "=== Non-exercise slide + demo counts per deck ==="
total_slides=0
total_demos=0
for f in slides/0*.qmd; do
  h1=$(grep -cE "^# " "$f")
  yt=$(grep -cE "^## Your turn" "$f")
  demos=$(grep -cE "^## Demos?( |$)" "$f")
  h2=$(grep -cE "^## " "$f")
  # Demos are timed separately (5-8 min each), so exclude them from content H2.
  content_h2=$((h2 - yt - demos))
  # Non-exercise slides = all H1 + content H2 (excluding demos) + 1 auto title slide (from YAML).
  non_ex=$((h1 + content_h2 + 1))
  echo "$f: H1=$h1, content H2=$content_h2, Your turn=$yt, demos=$demos, non-exercise total=$non_ex"
  total_slides=$((total_slides + non_ex))
  total_demos=$((total_demos + demos))
done
echo "Total non-exercise slides: $total_slides"
echo "Total demo slides: $total_demos"
```

## Schedule parsing

To total per-day session minutes from `index.qmd`:

```bash
# Each schedule row looks like:  | 09:00 - 10:10 | ... |
# Sum minutes per day by reading time ranges inside the day's table.
grep -E "^\| [0-9]{2}:[0-9]{2} - [0-9]{2}:[0-9]{2}" index.qmd
```

Then manually (or with an awk one-liner) sum `(end - start)` for non-break rows. Mark rows containing `*Break*` or `*Lunch break*` as breaks and exclude them from session time.

## Output format

A Markdown table like:

```
| Deck | Countdowns (min) | Non-exercise slides | Demos | Low estimate | High estimate |
|---|---|---|---|---|---|
| 01 ... | 40 | 20 | 2 | 70 | 96 |
...
| Total | 220 | 99 | 8 | ... | ... |
```

(Low = countdowns + non-exercise x 1 + demos x 5; High = countdowns + non-exercise x 2 + demos x 8. The deck 01 row above: 40 + 20 + 2x5 = 70 low, 40 + 40 + 2x8 = 96 high.)

Then a "Schedule" block showing minutes available per day and per workshop, and a one-line verdict.

## Tunable inputs

Allow the user to override:

- Minutes-per-content-slide (default 1-2).
- Minutes-per-demo (default 5-8).
- Whether section-divider H1 slides should count as 0.5 min instead of 1 (they tend to flash by quickly).
- Whether the title slide and "Thanks!" slide should count at all.

When the user asks for a specific tuning ("count section dividers as 30 seconds"), re-run with adjusted multipliers and produce a new table.

## When not to use this skill

- The user is asking about a single slide deck's length and not the whole workshop. (Run a simpler grep instead.)
- The repo is not a Quarto workshop project. The pattern matchers above will silently return zero and the output will be meaningless.
