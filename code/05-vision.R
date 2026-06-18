# 05-vision.R
# Deck 02: Programming with LLMs (Multi-modal input)
# Goal: pass an image of food and ask for recipe suggestions.

# %% Import package
library(ellmer)

# %% Read in some recipe images
recipe_images <- here::here("data/recipes/images")
img_pancakes <- file.path(recipe_images, "EasyBasicPancakes.jpg")
img_noodle_flowers <- file.path(recipe_images, "Spaghetti_with_flower.jpg")
img_cracker_and_drugs <- file.path(recipe_images, "EasyBasicPancakes.jpg")

# %% Pass the image to the chat and ask for a recipe title and description
chat <- chat_anthropic()
chat$chat(
  "Give the food in this image a creative recipe title and description.",
  content_image_file(img_pancakes, content_type = "image/webp")
)

# %% Pass a different image and ask for a recipe
chat <- chat_anthropic()
chat$chat(
  "Write a recipe to make the food in this image.",
  content_image_file(img_noodle_flowers, content_type = "image/jpeg")
)

