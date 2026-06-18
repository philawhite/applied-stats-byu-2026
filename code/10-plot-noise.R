# 10-plot-noise.R
# Deck 03: Prompt engineering and RAG (Prompt engineering and hallucinations)
# Goal: replace the mpg vs weight plot with random noise. Send the same prompt
# and see what the model says. Then work with a partner to coax the model into
# giving a "decent" interpretation of pure noise.

rm(list = ls())

# %% Import packages and generate data
library(ellmer)
library(ggplot2)
m <- 32
u <- (seq_len(floor(sqrt(m))) - 0.5) / floor(sqrt(m))
grid <- as.matrix(expand.grid(x = u, y = u))

eps <- 1 / (2 * sqrt(m))
jitter <- matrix(runif(length(grid), -eps, eps), ncol = 2)
grid_jitter <- pmin(pmax(grid + jitter, 0), 1)
mtcars <- as.data.frame(grid_jitter)
# %% Make a plot
ggplot(mtcars) +
  aes(x = x, y = y) +
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
