# 03-live.R
# Deck 01: Talking with LLMs via code (Shinychat basics)
# Goal: launch a live chat UI against an existing chat object using
# live_console() and live_browser().

# %% Import package and create chat
library(ellmer)
chat <- chat_anthropic()

# %% Converse with the chatbot in your console
live_console(___)

# %% After a bit, exit the chat and try chatting in a Shiny app.
live_browser(___)
