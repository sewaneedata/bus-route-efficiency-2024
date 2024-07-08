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

# Define UI for application that draws a histogram
ui <- fluidPage(

  
   
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    
}

# Run the application 
shinyApp(ui = ui, server = server)
