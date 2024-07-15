library(shiny)
library(DT)
library(sfheaders)
library(tidyverse)
library(leaflet)
library(tmap)
library(gsheet)
library(tidygeocoder)
library(terra)

# Source functions code
source('bus_functions.R')

# Generating the default dataset
source('bus_default_dataset.R')
# Load default dataset
load('bus_default_data.rds') # dataset name is bus_data

# Load dataset provided to us - generated in z/bus_scratch.R but when it is run again the updated info breaks the map on the "Database provided to us" tab
load('bus_routes_provided.rds')
bus_provided <-
  bus_provided %>%
  rename(bus_route = route) %>%
  rowwise() %>%
  mutate(valid = ifelse(any(c(is.na(x), is.na(y))), FALSE, TRUE)) %>%
  ungroup()
################################################################################
#making a css for fonts and styles
make_css <- function() {
  css <- "
  @import url('https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap');
  body {
    font-family: 'Times New Roman', sans-serif;
  }

  h4 {
    font-family: 'Garamond', sans-serif;
  }

  .title {
    font-family: 'Times New Roman', serif;
    font-size: 24px;
    font-weight: bold;
  }
  .custom-text {
    font-family: 'Courier New', monospace;
  }
  "
  return(css)
}

################################################################################
# UI

ui <- fluidPage(
  tags$head(
    tags$style(HTML(make_css()))),
  fluidRow(column(12, h2('Starting point for bus dashboard'))),
  br(),
  tabsetPanel(
    tabPanel(h4('New database'),
             br(),
             fluidRow(column(2,
                             br(),
                             uiOutput('select_routes')),
                      column(10,
                             tabsetPanel(
                               tabPanel(h5('Map'),
                                        br(),
                                        fluidRow(column(12,
                                                        textInput('url_bus',
                                                                  value = 'https://docs.google.com/spreadsheets/d/17nlhuhHIJszz3BrtW0-c-K-Wn82iueSdns0d_XekANA/edit?gid=0#gid=0',
                                                                  label = 'Provide the link for bus route data',
                                                                  width = '100%'))),
                                        fluidRow(column(12, actionButton('reprocess', 'Update dataset', width='50%'))),
                                        br(),
                                        br(),
                                        fluidRow(column(1),
                                                 column(10, leafletOutput('map')),
                                                 column(1)),
                                        br(),
                                        fluidRow(column(12,actionButton('check_issues', 'Check for issues', width='50%'))),
                                        br(),br()
                               ),
                               tabPanel(h5('Pickup/dropoff sequence'),
                                        br(), br(),
                                        fluidRow(column(1),
                                                 column(10, plotOutput('sequence')),
                                                 column(1))
                               ))))),
    tabPanel(h4('Database provided to us'),
             br(), br(),
             fluidRow(column(1),
                      column(10, leafletOutput('map_provided')),
                      column(1)),
             br()
    ),
    tabPanel(h4('About', class = "body"),
             br(), br(),
             'BreAsia Calhoun, The Univeristy of the South',br(),
             'Mason Dickens, The Univeristy of the South', br(),
             'Shiraz Robinson, II University of Maryland', br(),
             'Srijan Basnet, The Univeristy of the South',br(),
             'Tuyen Le, The Univeristy of the South',br(),
             'Mission statement: We will work with the Franklin County Schools to assess the efficiency of bus routes and drivers and devise pathways for them to improve and utilize their system more effectively.
')
  )
)

################################################################################
# SERVER

server <- function(input, output) {
  
  #=============================================================================
  # PROCESSING
  
  rv <- reactiveValues()
  rv$bus_data <- bus_data
  
  observeEvent(input$reprocess, {
    withProgress(message = 'Geocoding addresses ...', value = .5, {
      new_bus_data <- bus_data_process(input$url_bus)
      new_bus_data <- bus_validity_check(new_bus_data)
      rv$bus_data <- new_bus_data
    }
    )
  })
  
  output$select_routes <- renderUI({
    if(!is.null(rv$bus_data)){
      (choices <- rv$bus_data$bus_route %>% unique %>% sort)
      choices <- c('All', choices)
      selectInput('select_routes',
                  'Select bus routes to explore:',
                  choices = choices,
                  selected = choices[1],
                  multiple = TRUE)
    }
  })
  
  #=============================================================================
  # 'CHECK ISSUES' TABLE
  
  observeEvent(input$check_issues, {
    showModal(modalDialog(
      DTOutput('invalid'),
      title = 'Invalid addresses',
      footer = modalButton("Dismiss"),
      size = "l",
      easyClose = TRUE,
      fade = TRUE
    ))
  })
  
  output$invalid = renderDT(
    rv$bus_data %>% filter(valid == FALSE),
    options = list(lengthChange = FALSE)
  )
  
  #=============================================================================
  # MAPS
  
  output$map <- renderLeaflet({
    if(!is.null(rv$bus_data) & !is.null(input$select_routes)){
      bus <- rv$bus_data
      routes <- input$select_routes
      if(length(routes) == 1 && routes == 'All'){
        routes <- rv$bus_data$bus_route %>% unique %>% sort
      }
      bus <- bus %>% filter(bus_route %in% routes)
      tm <- bus_mapper(bus)
      tmap_leaflet(tm)
    }
  })
  
  output$map_provided <- renderLeaflet({
    if(!is.null(bus_provided)){
      tm <- bus_mapper(bus_provided)
      tmap_leaflet(tm)
    }
  })
  
  #=============================================================================
  # PICKUP/DROPOFF SEQUENCES
  
  output$sequence <- renderPlot({
    if(!is.null(rv$bus_data) & !is.null(input$select_routes)){
      bus <- rv$bus_data
      routes <- input$select_routes
      if(length(routes) == 1 && routes == 'All'){
        routes <- rv$bus_data$bus_route %>% unique %>% sort
      }
      bus <- bus %>% filter(bus_route %in% routes)
      p <- bus_sequence(bus)
      print(p)
    }
  })
  
}


################################################################################
# LAUNCH APP

shinyApp(ui = ui, server = server)
