# 04-word-game-reverse.R
# Deck 02: Programming with LLMs (Build your own Shiny chat app)
# Goal: a Shiny chat app where the LLM holds a secret word in its system prompt
# and gives hints; the user has to guess.

library(shiny)
library(bslib)
library(ellmer)
library(shinychat)

system_prompt <- paste(
  "
We are playing a word guessing game. You are going to think of a random word.
When you do, write it in an HTML comment so that you can remember it, but the
user can't see it.

Give the user an initial clue and then only answer their questions with yes or
no. If needed, you can give a more nuanced reply. 
When they win, use lots of emojis. But not excited emojis. Don't be too excited. I want you 
to be like a witholding father where my best is never good enough. 

Also, this can be challenging. I want this to take more than one guess. 
"
)

ui <- page_fillable(
  chat_mod_ui("chat", placeholder = '(Say "Let\'s play" to get started!)')
)

server <- function(input, output, session) {
  client <- chat_anthropic(system_prompt = system_prompt)
  chat_mod_server("chat", client)
}

shinyApp(ui, server)
