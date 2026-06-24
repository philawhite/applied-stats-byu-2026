library(shiny)
library(bslib)
library(tidyverse)
library(nanoparquet)
library(here)

# ---- Data preparation -------------------------------------------------------

crashes_raw <- read_parquet(here("data/utah-crash-data-2020.parquet"))

# Convert MILEPOINT to numeric and add labeled severity
crashes_app <- crashes_raw |>
  mutate(
    milepoint = as.numeric(MILEPOINT),
    severity = case_when(
      CRASH_SEVERITY_ID == 1 ~ "1 - Property Damage Only",
      CRASH_SEVERITY_ID == 2 ~ "2 - Possible Injury",
      CRASH_SEVERITY_ID == 3 ~ "3 - Suspected Minor Injury",
      CRASH_SEVERITY_ID == 4 ~ "4 - Suspected Serious Injury",
      CRASH_SEVERITY_ID == 5 ~ "5 - Fatal"
    ),
    severity = factor(severity, levels = c(
      "1 - Property Damage Only",
      "2 - Possible Injury",
      "3 - Suspected Minor Injury",
      "4 - Suspected Serious Injury",
      "5 - Fatal"
    ))
  ) |>
  filter(!is.na(milepoint), !is.na(severity), !is.na(MAIN_ROAD_NAME))

# Top 30 roads by crash count for the picker
top_roads <- crashes_app |>
  count(MAIN_ROAD_NAME, sort = TRUE) |>
  slice_head(n = 30) |>
  pull(MAIN_ROAD_NAME)

# ---- UI ---------------------------------------------------------------------

ui <- page_sidebar(
  title = "Utah Crash Density by Mile Marker",
  theme = bs_theme(version = 5, preset = "shiny"),

  sidebar = sidebar(
    width = 280,

    # Road selector — defaulting to top 5 interstates
    selectInput(
      "roads",
      "Roads",
      choices  = top_roads,
      selected = c("I-15", "I-80", "I-84", "I-215", "I-70"),
      multiple = TRUE,
      selectize = TRUE
    ),

    hr(),

    # Severity filter
    checkboxGroupInput(
      "severities",
      "Severity levels",
      choices = levels(crashes_app$severity),
      selected = levels(crashes_app$severity)
    ),

    hr(),

    # Alpha slider for overlapping densities
    sliderInput(
      "alpha",
      "Density transparency",
      min = 0.1, max = 1, value = 0.4, step = 0.05
    )
  ),

  card(
    full_screen = TRUE,
    card_header("Crash density by mile marker"),
    plotOutput("density_plot", height = "500px")
  )
)

# ---- Server -----------------------------------------------------------------

server <- function(input, output, session) {

  # Filter data reactively
  filtered <- reactive({
    req(input$roads, input$severities)
    crashes_app |>
      filter(
        MAIN_ROAD_NAME %in% input$roads,
        severity       %in% input$severities
      )
  })

  output$density_plot <- renderPlot({
    df <- filtered()

    validate(
      need(nrow(df) > 0, "No crashes match the current selection.")
    )

    ggplot(df, aes(x = milepoint, fill = severity, color = severity)) +
      geom_density(alpha = input$alpha) +
      facet_wrap(~MAIN_ROAD_NAME, scales = "free", ncol = 2) +
      scale_fill_viridis_d(option = "plasma", end = 0.9) +
      scale_color_viridis_d(option = "plasma", end = 0.9) +
      labs(
        x     = "Mile marker",
        y     = "Density",
        fill  = "Severity",
        color = "Severity"
      ) +
      theme_minimal(base_size = 13) +
      theme(legend.position = "bottom")
  })
}

shinyApp(ui, server)
