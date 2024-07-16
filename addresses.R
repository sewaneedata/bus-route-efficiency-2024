library(sf)
library(tmap)
library(osmdata)
library(tidycensus)
library(tidyverse)
library(mapsapi)
library(geodata)

us <- gadm( country = "United States", level = 2, path = "./")
us <- st_as_sf( us )
franklin <- us %>% filter( NAME_1 == "Tennessee", NAME_2 == "Franklin")
bbox <- st_bbox( franklin )



# CHANGE THIS STRING TO YOUR GOOGLE MAPS API KEY!!!!!!!
key <- "YOUR GOOGLE MAPS API KEY GOES HERE!"



bus_routes <- gsheet::gsheet2tbl("https://docs.google.com/spreadsheets/d/12Qj9yy1YgqnOWQk3qDCRP9LjsEQUckdJz9DPwogGDSM/edit?pli=1&gid=0#gid=0") %>% 
  mutate( Address = paste0( Address, " 'Franklin County' TN" ) )

bus_geocodes <- mp_geocode( unique( bus_routes$Address ), key = key, quiet = TRUE ) # postcode = c(37306,37318,37324,37330,37345,37375,37376,37383,37398))

bus_points <- mp_get_points( bus_geocodes )

tmap_mode("view")
tmap_options( basemaps = providers$CartoDB.Positron )
tm_shape( franklin ) +
  tm_polygons( alpha = 0.2 ) +
  tm_shape( bus_points ) +
  tm_dots( id = "Address" )


# Saving the GIS data to an RData file
dir.create("data", showWarnings = FALSE)
save( bus_points, franklin, file="data/bus_gis.RData" )
