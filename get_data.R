# load libraries
library(sf)
library(tmap)
library(osmdata)
library(tidycensus)
library(tidyverse)
library(mapsapi)
library(geodata)

#load bus data
bus_routes <- gsheet::gsheet2tbl("https://docs.google.com/spreadsheets/d/12Qj9yy1YgqnOWQk3qDCRP9LjsEQUckdJz9DPwogGDSM/edit?pli=1&gid=0#gid=0") %>% 
  mutate( Address = paste0( Address, " 'Franklin County' TN" ) )

#Need to ask Dr.Rudd about this data.
load("data/bus_gis1.RData")

#Need to ask Dr.Rudd what these lines do.
bus_routes <- left_join( bus_points %>% select( Address = address, address_google, location_type, pnt ), bus_routes, by = "Address")
#Convert bus into levels.
bus_routes$Bus <- factor( as.character(bus_routes$Bus) )

# make bus map

tmap_mode( "view" )
tmap_options( basemaps = providers$OpenStreetMap )

tm_shape( franklin ) + 
  tm_polygons( alpha = 0.5, lwd=3 ) +
  tm_shape( bus_routes ) +
  tm_dots( col="Bus" )


