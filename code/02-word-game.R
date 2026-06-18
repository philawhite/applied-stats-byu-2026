# 02-word-game.R
# Deck 01: Talking with LLMs via code (Anatomy of a conversation)
# Goal: play a word guessing game where the LLM is the guesser. The first user
# message includes a modifier (e.g. "In British English,") that steers later
# turns; this shows how the conversation carries state in the message history.

# %% Import package
library(ellmer)

# %% Set up a chat with a system prompt
chat <- chat_anthropic(
  system_prompt = paste(
    "We are playing a word guessing game.",
    "At each turn, you guess the word and tell us what it is."
  )
)

# Ask the first question:
chat$chat("In American English, guess the word for the person who lives next door. Please, if you can, connect it to old english roots and associated germanic words.")

# Ask the second question:
chat$chat("What helps a car move smoothly down the road?")

chat$chat("Can you speak many languages in this chat or does this need to be in English?")


chat$chat("Let's play the word guessing game, now in American English. You ask questions, and I'll respond with yes or no. Let's see how many steps it takes for you to guess.")


# %% Compare with...
chat2 <- chat_anthropic()
chat2$chat("What helps a car move smoothly down the road?")
