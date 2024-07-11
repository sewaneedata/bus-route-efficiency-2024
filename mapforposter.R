# Load libraries
library(sf)
library(tmap)
library(osmdata)
library(tidycensus)
library(tidyverse)
library(mapsapi)
library(geodata)
library(leaflet)
library(gsheet)
library(dplyr)

# Load bus routes data

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

# Convert Bus numbers to characters
bus_routes$Bus <- as.character(bus_routes$Bus)

#Counting the number of every kid on each bus and putting it into the dataset
bus_routes <- bus_routes %>%
  group_by(Bus) %>%
  mutate(num_kid_per_bus = n()) %>% 
  ungroup()
#This will count the number of bus stops by removing repeat locations
bus_routes <- bus_routes %>%
  group_by(Bus) %>%
  mutate(unq_add = n_distinct(Address)) %>%
  ungroup()
#This shows the bus that could be overcrowded. 
bus_over_48 <- bus_routes %>%
  filter(num_kid_per_bus > 48) %>% 
  distinct(Bus)
print(bus_over_48)
bus_routes_summary <- bus_routes %>%
  group_by(Bus) %>%
  summarize(num_kid_per_bus = n()) %>%
  ungroup()
bus_routes_summary<- st_drop_geometry(bus_routes_summary)

# Convert Bus numbers to factors to enable automatic coloring on the map
bus_routes$Bus <- factor(bus_routes$Bus, levels = c("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12",
                                                    "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24",
                                                    "25", "26", "28", "29", "30", "32", "35", "36", "38", "41", "48",
                                                    "49", "51", "52", "53", "54"))

# Make the map interactive
tmap_mode("plot")
# tmap_options(basemaps = providers$OpenStreetMap)

# Create the base map with Franklin County Border
map <- tm_shape(franklin, name = "Franklin County Border") +
  tm_polygons(alpha = 0.5, lwd = 3)

# Define colors for schools
unique_schools <- unique(schools$SCHOOL)
colors <- rainbow(length(unique_schools))  # Generate a set of distinct colors
names(colors) <- unique_schools

# Add school data to the bus route map with different colors
for (school in unique_schools) {
  color <- colors[school]
  map <- map +
    tm_shape(schools %>% filter(SCHOOL == school), name = school) +
    tm_dots(col = color, id = 'SCHOOL', size = 0.1, legend.show = TRUE)
}

# Add bus routes to the map
buses <- levels(bus_routes$Bus)
buses
pal <- colorRampPalette(colors = c('red', 'yellow', 'green', 'blue', 'violet'))
(bus_colors <- pal(length(buses)))
bus = '1'
for (busi in 1:length(buses)) {
  bus <- buses[busi]
  colori <- bus_colors[busi]
  map <- map +
    tm_shape(bus_routes %>% filter(Bus == bus), name = paste0("Bus Route ", bus)) +
    tm_dots(col = colori, id = "Address", size = 0.1, legend.show = TRUE)
  
# Add lines in bus route
   (bus_line <- bus_routes %>% filter(Bus == bus))
   (bus_line <- as_Spatial(bus_line))
   (bus_line <- as(bus_line, 'SpatialLines'))
   map <- map + tm_shape(bus_line, name = paste0('Bus Line ', bus)) + 
   tm_lines(col = colori)
 }

map
# Convert to leaflet and display the map
# leaflet_map <- tmap_leaflet(map)
# leaflet_map


# Getting unique values of bus routes to unselect the layers by default. 
bus_route_names <- unique( paste0( "Bus Route ", bus_routes$Bus ) )
map %>% 
  tmap_leaflet( ) %>%
  hideGroup( bus_route_names ) 
  


