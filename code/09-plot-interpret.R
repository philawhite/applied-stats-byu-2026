# 09-plot-interpret.R
# Deck 03: Prompt engineering and RAG (Prompt engineering and hallucinations)
# Goal: generate a plot of mpg vs weight from mtcars and ask the model to
# interpret it.

# %% Import packages and load data
library(readr)
library(ellmer)
library(ggplot2)
mtcars <- read_csv(here::here("data/mtcars.csv"))

# %% Make a plot
ggplot(mtcars) +
  aes(x = wt, y = mpg) +
  geom_point(color = "steelblue", size = 3) +
  labs(
    title = "MPG vs Weight",
    x = "Weight (1000 lb)",
    y = "Miles per Gallon (mpg)"
  ) +
  theme_bw()

# %% Send the plot to the model and ask for an interpretation
chat <- chat_anthropic()
chat$chat("Interpret this plot of mtcars.", content_image_plot())
