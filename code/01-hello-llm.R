# 01-hello-llm.R
# Deck 01: Talking with LLMs via code (Set-up and verify API access)
# Goal: verify API access by writing a short poem about SIAS 2026.

# %% Import package
library(ellmer)

# %% Verify API access by writing a short poem about SIAS 2026
chat <- chat_anthropic()
chat$chat(
  "I'm at SIAS 2026 to learn about programming with LLMs and ellmer!",
  "Write a short poem or limerick to celebrate."
)
