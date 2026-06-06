# 08-batch.R
# Deck 02: Programming with LLMs (Parallel and batch calls)
# Goal: run the structured recipe extraction across many PDFs in parallel.
# Save the JSON output so we can reuse it in later exercises.

# %% Import package
library(ellmer)

# %% Read in the recipes from text files (this time all of the recipes)
recipe_files <- fs::dir_ls(here::here("data/recipes/text"))
recipes <- purrr::map(recipe_files, brio::read_file)

# %% Let's use the same type object from the last exercise
type_recipe <- type_object(
  title = type_string(),
  description = type_string(),
  ingredients = type_array(
    type_object(
      name = type_string(),
      quantity = type_number(),
      unit = type_string(required = FALSE),
      notes = type_string(required = FALSE)
    )
  ),
  instructions = type_array(type_string())
)

# %% Use a simple loop to process each recipe one at a time (can be slow and expensive!)
recipes_data <- parallel_chat_structured(
  chat("anthropic/claude-haiku-4-5"),
  prompts = recipes,
  type = type_recipe
)

# %% What did we get?
recipes_tbl <- dplyr::as_tibble(recipes_data)
recipes_tbl

# %% We can save money by using the Batch API
#
# With the Batch API, results are processed asynchronously and are completed at
# some point, usually within a few minutes but at most within the next 24 hours.
# Because batching lets providers schedule requests more efficiently, it also
# costs less per token than the standard API.
res <- batch_chat_structured(
  chat("anthropic/claude-haiku-4-5"),
  prompts = recipes,
  type = type_recipe,
  path = here::here("data/recipes/batch_results_r_claude.json")
)

# %% Now, save the results to a JSON file in `data/recipes/recipes.json`
jsonlite::write_json(
  res,
  here::here("data/recipes/recipes.json"),
  auto_unbox = TRUE,
  pretty = TRUE
)

# Once you've done that, you can open up `08-batch-app.R` and run the app to see
# your new recipe collection!
