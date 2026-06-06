# 09-plot-interpret.py
# Deck 03: Prompt engineering and RAG (Prompt engineering and hallucinations)
# Goal: generate a plot of mpg vs weight from mtcars and ask the model to
# interpret it.

# %% Import packages and load data
import chatlas
import dotenv
import polars as pl
from matplotlib import pyplot as plt
from plotnine import aes, geom_point, ggplot, labs, theme_bw
from pyhere import here

dotenv.load_dotenv()
mtcars = pl.read_csv(here("data/mtcars.csv"))
mtcars

# %% Make a plot
p = (
    ggplot(mtcars, aes(x="wt", y="mpg"))
    + geom_point(color="steelblue", size=2)
    + labs(title="MPG vs Weight", x="Weight (1000 lb)", y="Miles per Gallon (mpg)")
    + theme_bw()
)
p.show()

# Register the plot with matplotlib's current figure
plt.figure(p.draw())

# %% Send the plot to the model and ask for an interpretation
chat = chatlas.ChatAnthropic()
chat.chat("Interpret this plot of mtcars.", chatlas.content_image_plot(),)