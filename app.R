library(shiny)
library(rsconnect)
library(tidyverse)
library(shinythemes)
library(thematic)
library(urbnmapr)
library(colorspace)

# Load data --------------------------------------------------------------------
business <- read_csv("business.csv", show_col_types = FALSE)

state_choices <- business$State %>% unique()

type_choices <- business$business_vertical %>% unique()

# import sf for the county-level map
counties_sf <- get_urbn_map(map = "counties", sf = TRUE)

# merge air quality data and sf using fips code
counties_act <- left_join(counties_sf, business,
                           by = c("county_fips" = "FIPS"))

# Define UI --------------------------------------------------------------------
ui <- fluidPage(
  theme = shinytheme("united"),
  titlePanel("Impact of COVID-19 on Business Activities of U.S. Counties in 2020"),
  "A Shiny app built by Eva Wu, Zhiyun Hu, Pawel Rybacki, Haohan Shi, and Yi Wang",
  br(), br(),
  sidebarLayout(
    sidebarPanel(
      radioButtons(
        inputId = "type",
        label = "Select a business type:",
        choices = type_choices,
        selected = "Restaurants" # placeholder type
      )
    ),
    mainPanel(
      tabsetPanel(
        # tab 1======
        tabPanel(
          "Map",
          br(),
          dateInput(
            inputId = "date",
            label = "Select a date:",
            value = "2020-03-10", # placeholder date
            min = "2020-03-10",
            max = "2020-12-31",
            format = "yyyy-mm-dd", # default
          ),
          textOutput(outputId = "map_text"),
          plotOutput("map")
        )
      )
    )
  )
)

# Define server function --------------------------------------------
server <- function(input, output) {

  # [tab 1: the map] ========================

  output$map_text <- reactive({
    paste0("This map shows the business activity of ", input$type, 
          " across the U.S. on ", input$date, ". Activity quantile > .5 (red) means increased business activity; 
          activity quantile = .5 (white) means normal business activity; 
          activity < .5 (blue) means decreased business activity. 
          Counties with NA values are filled with grey.")
  })

  output$map <- renderPlot({

    counties_act %>%
      filter(ds == input$date & business_vertical == input$type) %>%
      ggplot() +
      geom_sf(data = counties_sf, fill = "grey50", color = "grey80") +
      geom_sf(mapping = aes(fill = activity_quantile, color = activity_quantile)) +
      scale_fill_continuous_diverging(palette = "Blue-Red 3", 
                                      aesthetics = c("color", "fill"), # make color & fill consistent
                                      mid = 0.5) +
      theme_void() +
      labs(title = "Map showing county-level business activity for restaurants",
           fill = "Activity quantile", color = "Activity quantile") +
      theme(legend.position = "left")

  })
  
}

# Create the Shiny app object ---------------------------------------
thematic_shiny()
shinyApp(ui = ui, server = server)
