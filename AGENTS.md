# Posit Assistant Memory — applied-stats-byu-2026

## Project context

SIAS 2026 workshop on "Programming with LLMs for Data Practitioners" (BYU, June 17-18 2026, taught by Julia Silge). Day 2 uses a single running dataset (Utah crashes) for all exercises and demos. Phil White is a participant working on his own crash severity analysis.

---

## Primary dataset

**File**: `data/utah-crash-data-2020.parquet`
**Load with**: `nanoparquet::read_parquet(here::here("data/utah-crash-data-2020.parquet"))`
**Rows**: ~252,500 Utah crash records (year 2020)

### Key columns

| Column | Type | Notes |
|---|---|---|
| `CRASH_SEVERITY_ID` | int | 1=Property Damage Only, 2=Possible Injury, 3=Suspected Minor Injury, 4=Suspected Serious Injury, 5=Fatal. 4 NAs present. |
| `CRASH_DATETIME` | datetime | Use `lubridate::hour()` etc. to extract time components. |
| `COUNTY_NAME` | chr | County name (all caps). Note: column is `COUNTY_NAME`, NOT `COUNTY`. |
| `MILEPOINT` | **chr** | Stored as character despite being numeric. Always convert: `as.numeric(MILEPOINT)`. |
| `CITY` | chr | City name. |
| `ROUTE` | chr | Road route identifier. |
| `LAT_UTM_Y`, `LONG_UTM_X` | dbl | Coordinates in UTM (not lat/lon). |

### Binary risk-factor columns (19 total, values TRUE/FALSE)

`WORK_ZONE_RELATED`, `PEDESTRIAN_INVOLVED`, `BICYCLIST_INVOLVED`, `MOTORCYCLE_INVOLVED`, `IMPROPER_RESTRAINT`, `UNRESTRAINED`, `DUI`, `INTERSECTION_RELATED`, `WILD_ANIMAL_RELATED`, `DOMESTIC_ANIMAL_RELATED`, `OVERTURN_ROLLOVER`, `COMMERCIAL_MOTOR_VEH_INVOLVED`, `TEENAGE_DRIVER_INVOLVED`, `OLDER_DRIVER_INVOLVED`, `NIGHT_DARK_CONDITION`, `SINGLE_VEHICLE`, `DISTRACTED_DRIVING`, `DROWSY_DRIVING`, `ROADWAY_DEPARTURE`

### Known data quirks

- `MILEPOINT` is character; must use `as.numeric()` before arithmetic.
- `CRASH_SEVERITY_ID` has 4 NAs (drop before modeling).
- ~1,935 rows have NAs in one or more risk-factor columns; `MASS::polr()` drops these silently.
- The column for county is `COUNTY_NAME`, not `COUNTY`.

---

## Phil's analysis

**File**: `code/crash-severity-analysis.qmd`
**Topic**: How do the 19 binary risk factors relate to crash severity?

**Approach**:
1. Collapse severity 4 and 5 into "4+" (serious injury / fatal) due to low counts at severity 5 (n=968).
2. Bivariate stacked bar charts and ranked dot plot of % serious/fatal per factor.
3. Ordinal logistic regression (`MASS::polr()`) with all 19 factors; odds ratios plotted with 95% CI.
4. Proportional odds LRT comparing `polr()` to `nnet::multinom()` (LRT=3136.5, df=38, p<<0.001 -- assumption is violated but n~250k makes any violation detectable).

**Key findings** (from the model): pedestrian and bicycle involvement have the largest ORs (~29 and ~24 respectively); wild-animal and single-vehicle crashes show negative coefficients (associated with lower severity after controlling for other factors).

---

## R packages used in Phil's analysis

`tidyverse`, `nanoparquet`, `here`, `MASS` (polr), `nnet` (multinom), `broom`

---

## Other workshop code files

All numbered `code/NN-name.{R,py}` files are workshop exercise skeletons (01-15). `code/crash_data.R` is an exploratory scratch file for the crash dataset. Do not edit numbered workshop files unless asked.
