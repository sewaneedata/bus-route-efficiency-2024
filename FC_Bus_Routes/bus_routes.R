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

# Reads in the school data
schools <- gsheet::gsheet2tbl("https://docs.google.com/spreadsheets/d/1SZl3nINhH9V832c_KYjxHGKEfWM4bSwYMRpCgNZg5XM/edit?gid=0#gid=0")

# Transforms the school data into long/lat coordinates.
schools <- st_as_sf(schools, coords = c("LONG", "LAT"), crs = "EPSG:4326")

bus_routes <- gsheet::gsheet2tbl("https://docs.google.com/spreadsheets/d/12Qj9yy1YgqnOWQk3qDCRP9LjsEQUckdJz9DPwogGDSM/edit?pli=1&gid=0#gid=0") %>%
  mutate(Address = paste0(Address, " 'Franklin County' TN"))

# Load latitude and longitude data of addresses
load("data/bus_gis.RData")

# Add longitude and latitude to the data frame
bus_routes <- left_join(bus_points %>% select(Address = address, address_google, location_type, pnt), bus_routes, by = "Address")

################################################################################
# UI

ui <- fluidPage(
  
  textInput('url_bus',
            value = 'https://docs.google.com/spreadsheets/d/1SZl3nINhH9V832c_KYjxHGKEfWM4bSwYMRpCgNZg5XM/edit?gid=0#gid=0'
            label = 'Provide the link to your GoogleSheet'),
  
  extInput('url_addresses',
           value = ''
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









