#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

# load libraries 

library(shiny)
library(sf)
library(tmap)
library(osmdata)
library(tidycensus)
library(tidyverse)
library(mapsapi)
library(geodata)
library(leaflet)
library(gsheet)
library(ggplot2)
library(dplyr)
library(DT)


# practice url
# https://docs.google.com/spreadsheets/d/11ak0g0lD4wstiQfWhGnYeVxSZlL01Bw5VEpg0CpLhTM/edit?usp=sharing'

################################################################################
# UI

ui <- fluidPage(
  
  textInput('url',
            label = 'Provide the link to your GoogleSheet'),
  
  DT::dataTableOutput("mytable1")
  
  
)


################################################################################
# SERVER

server <- function(input, output) {
  
  output$mytable1 <- DT::renderDataTable({
    df <- gsheet2tbl(input$url)
    Sys.sleep(1)
    DT::datatable(df)
  })
  
}

################################################################################
# LAUNCH APP

shinyApp(ui = ui, server = server)










