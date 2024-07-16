library(shiny)
library(DT)
library(sfheaders)
library(tidyverse)
library(leaflet)
library(tmap)
library(gsheet)
library(tidygeocoder)
library(terra)
library(sf)
library(bslib)

# Source functions code
source('../bus_functions.R')

# To re-generate the below datasets, un-comment and run the following line
# source('../get_data.R')

# Load default dataset
load('../data/bus_default_data.rds') # dataset name is bus_data

# Loading the bus route dataset
load('../data/bus_routes.rds')


# Prep data for provided bus routes ============================================

bus_provided <- bus_routes
rm(bus_routes)

bus_provided <-
  bus_provided %>%
  rename(bus_route = Bus) %>%
  rowwise() %>%
  mutate(valid = TRUE) %>%  
  ungroup()

################################################################################
#making a css for fonts and styles
#' make_css <- function() {
#'   css <- "
#'   @import url('https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap');
#'   
#'   
#'   h2{ 
#'   font-family: 'Times New Roman', sans-serif;
#'   }
#'   h5{
#'   font-family: 'Garamond', serif;
#'   }
#' 
#'   h4 {
#'     font-family: 'Courier New', sans-serif;
#'   }
#' 
#'   .title {
#'     font-family: 'Times New Roman', serif;
#'     font-size: 24px;
#'     font-weight: bold;
#'   }
#'   .custom-text {
#'     font-family: 'Courier New', monospace;
#'   }
#'   "
#'   return(css)
#' }

################################################################################
# UI

ui <- page_navbar(
  
  theme = bs_theme(bootswatch = 'flatly'),
  
  
  
  # tags$head(
  #   tags$style(HTML(make_css()))),
  fluidRow(column(12, h2('Bus Routes of Franklin County Schools'))),
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
                                        fluidRow(column(12, actionButton('reprocess', 'Update dataset', width='50%', class="btn btn-primary"))),
                                        br(),
                                        br(),
                                        fluidRow(column(1),
                                                 column(10, leafletOutput('map')),
                                                 column(1)),
                                        br(),
                                        fluidRow(column(12,actionButton('check_issues', 'Check for issues', width='50%', class="btn btn-primary"))),
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
             fluidRow(
               column(2),
               column(
                 3,
                 fluidRow(
                   tags$img(src = 'Jan.jpeg', width = "75%", alt = "Picture of Jan", align = "center")
                 ),
                 fluidRow(
                   p('Jan Davis, Franklin County School District\nTransportation Administrative Assistant P/T', align = "center")
                 )
               ),
               column(2),
               column(
                 3,
                 fluidRow(
                   tags$img(src = 'Jeff.jpeg', width = "75%", alt = "Picture of Jeff", align = "center")
                 ),
                 fluidRow(
                   p('Jeff Sons, Franklin County School District\nTransportation Director', align = "center")
                 )
             ),
             column(2)
             ),
             fluidRow(
               column(1),
               column(
                 2,
                 fluidRow(
                   tags$img(src = 'BreAsia.jpg', width = "75%", alt = "Picture of BreAsia", align = "center")
                 ),
                 fluidRow(
                   p('BreAsia Calhoun, University of the South', align = "center")
                 )
               ),
               column(
                 2,
                 fluidRow(
                   tags$img(src = 'Mason.jpg', width = "75%", alt = "Picture of Mason", align = "center")
                 ),
                 fluidRow(
                   p('Mason Dickens, University of the South', align = "center")
                 )
               ),
               column(
                 2,
                 fluidRow(
                   tags$img(src = 'Shiraz.jpg', width = "75%", alt = "Picture of Shiraz", align = "center")
                 ),
                 fluidRow(
                   p('Shiraz Robinson II, University of Maryland', align = "center")
                 )
               ),
               column(
                 2,
                 fluidRow(
                   tags$img(src = 'Srijan.jpg', width = "75%", alt = "Picture of Srijan", align = "center")
                 ),
                 fluidRow(
                   p('Srijan Basnet, University of the South', align = "center")
                 )
               ),
               column(
                 2,
                 fluidRow(
                   tags$img(src = 'Tuyen.png', width = "85%", alt = "Picture of Tuyen", align = "center")
                 ),
                 fluidRow(
                   p('Tuyen Le, University of the South', align = "center")
                 )
               ),
               column(1)
             ),
             br(),
             div(strong('Background:'), p('Franklin County public schools manage 32 buses for 1,779 K-12 students across 39 routes, employing 28 contracted drivers for 11 schools. Due to driver shortages, some run double routes, and all drivers handle dispersed home pickups, being compensated for up to 110 miles daily. Challenges include increased student numbers from new housing developments, a shortage of both regular and special education drivers, and capacity limits, all managed by only two people in the Department. Buses struggle with overcrowding, longer routes due to more stops, and adherence to a 90-minute transit limit, further complicated by communication issues with parents and illegal actions by other drivers at student drop-offs. Additionally, incomplete maps hinder route planning. The Department seeks our analysis to propose more efficient routes meeting three criteria: safe transit within the 90-minute limit, doorstep pickups to avoid traffic hazards, and accommodating growing student numbers due to new constructions. They need our help to optimize these routes ahead of the new school term in August, addressing connectivity and capacity challenges efficiently.')
               )
)))


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

