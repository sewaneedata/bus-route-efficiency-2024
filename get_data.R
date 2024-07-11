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

# Load bus routes data and edit it ##############################

# Reads in the school names and addresses
schools <- gsheet::gsheet2tbl("https://docs.google.com/spreadsheets/d/1SZl3nINhH9V832c_KYjxHGKEfWM4bSwYMRpCgNZg5XM/edit?gid=0#gid=0")

# Transforms the school data into long/lat coordinates.
schools <- st_as_sf(schools, coords = c("LONG", "LAT"), crs = "EPSG:4326")

# this loads in the location of each student 
bus_routes <- gsheet::gsheet2tbl("https://docs.google.com/spreadsheets/d/12Qj9yy1YgqnOWQk3qDCRP9LjsEQUckdJz9DPwogGDSM/edit?pli=1&gid=0#gid=0") %>%
  # this was added to each address to keep all locations in Franklin County
  mutate(Address = paste0(Address, " 'Franklin County' TN"))

# Load latitude and longitude data of addresses
load("data/bus_gis.RData")

# Add longitude and latitude to the data frame
bus_routes <- left_join(bus_points %>% 
                          select(Address = address, 
                                 address_google, 
                                 location_type, 
                                 pnt), bus_routes, by = "Address")

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




# Make the map #########################

#This shows the bus that could be overcrowded.
# Overcrowded is defined by having more than 48 kids
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
tmap_mode("view")
tmap_options(basemaps = providers$OpenStreetMap)

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
for (bus in buses) {
  map <- map +
    tm_shape(bus_routes %>% filter(Bus == bus), name = paste0("Bus Route ", bus)) +
    tm_dots(col = "School", id = "Address", size = 0.1, legend.show = FALSE)
}

# Convert to leaflet and display the map
# leaflet_map <- tmap_leaflet(map)
# leaflet_map


# Getting unique values of bus routes to unselect the layers by default. 
bus_route_names <- unique( paste0( "Bus Route ", bus_routes$Bus ) )
map %>% 
  tmap_leaflet( ) %>%
  hideGroup( bus_route_names ) 

#making a column that says if there is a turn by turn document
bus_routes <- bus_routes %>% 
  mutate(turn_by_turn = if_else(Bus %in% c(1,2,3,4,6,7,8,9,10,11,12,15,16,18,19,21,22,24,25,26,28,29,30,32,35,36,38,89,42,49,51,52,53,54),"yes","no"))





# Mapping out bus routes with the turn by turn ##################


#checking the number of buses that have a turn by turn
bus_routes %>% 
  distinct(Bus, .keep_all = TRUE) %>% 
  group_by(turn_by_turn) %>% 
  tally()

#pick the bus route that has a turn by turn and the least number of stops
bus_routes %>% 
  filter(turn_by_turn == "yes") %>% 
  distinct(Bus, .keep_all = TRUE) %>%
  arrange(unq_add) %>% 
  select(Bus, unq_add)
 
# we will look at bus 28 due to it being short and having a turn by turn for testing
bus_28 <- bus_routes %>% 
  filter(Bus == 28) %>% 
  mutate(order = case_when(
    Address == "221 Huckleberry Ln 'Franklin County' TN" ~1,
    Address == "50 Circle E Ln 'Franklin County' TN" ~2,
    Address == "Circle E Guest Ranch 'Franklin County' TN" ~3,
    Address == "541 Iron Gap Rd 'Franklin County' TN" ~ 4, 
    Address == "Old Shook Rd 'Franklin County' TN"~5,
    Address == "2730 Keith Springs Mt. Rd 'Franklin County' TN"~6,
    Address == "21 Foggy Mt. Ln 'Franklin County' TN"~7,
    Address == "4858 Keith Springs Mt. Rd 'Franklin County' TN"~8,
    Address == "110 Pinon Ln 'Franklin County' TN"~9, #this needs to be pinion
    Address == "Keith Springs Mt. Rd 'Franklin County' TN"~10,
    Address == "Keith Springs Mt.Copperhead Rd 'Franklin County' TN" ~11,
    Address == "Keith Springs  Mt. Copperhead Rd 'Franklin County' TN" ~11,#one is missing a space 
    Address == "4185 Keith Springs Mt. Rd 'Franklin County' TN" ~12,
    Address == "Clark Memorial"~13,#we need to add this
    Address == "Franklin County High School"~14,#we need to add this
    Address == "South Middle School"~15,#we need to add this
    TRUE ~ NA
  ))


# now we are looking at huntland routes that potentially could be combined
# these bus routes are 9, 10, 16, 21, 36, and 22

# make a dataset for these buses
huntland_routes <- bus_routes %>% 
  filter(Bus %in% c(9, 10, 16, 21, 36,22)) %>% 
  filter(turn_by_turn == "yes")

#find the shortest routes
huntland_routes %>% 
  distinct(Bus, .keep_all = TRUE) %>%
  arrange(unq_add) %>% 
  select(Bus, unq_add)

# create an order column that says the order that buses visit the households in bus 36
bus_36 <- huntland_routes %>% 
  filter(Bus == 36)%>% 
  mutate(order = case_when(
    Address == "196 Strope Ln 'Franklin County' TN"  ~1,
    Address == "106 Old Beans Creek Rd 'Franklin County' TN" ~2,
    Address == "209 Kennedy Ln 'Franklin County' TN"  ~3,
    Address == "2239 Hickory Grove Rd 'Franklin County' TN" ~4,
    Address == "2105 Hickory Grove Rd 'Franklin County' TN" ~5,
    Address == "2045 Sugar Cove Rd 'Franklin County' TN" ~6,
    Address == "280 George Hall Rd 'Franklin County' TN" ~7,
    Address == "1150 Foster Ln 'Franklin County' TN"  ~8,
    Address == "1047 Foster Ln 'Franklin County' TN"  ~9,
    Address == "364 Foster Ln 'Franklin County' TN"  ~10,
    Address == "229 Maxwell Rd 'Franklin County' TN"  ~11,
    Address == "18 Maxwell Rd 'Franklin County' TN"  ~12,
    Address == "46 Walnut Hill Rd 'Franklin County' TN"  ~13,
    Address == "121 Beans Creek Rd 'Franklin County' TN"  ~14,
    Address == "1777 Beans Creek Rd 'Franklin County' TN"  ~15,
    Address == "1913 Beans Creek Rd 'Franklin County' TN"  ~16,
    Address == "2396 Beans Creek Rd 'Franklin County' TN"  ~17,
    Address == "2534 Beans Creek Rd 'Franklin County' TN"  ~18,
    Address == "2160 Francisco Rd 'Franklin County' TN" ~ 19,
    Address == "319 Alabama St 'Franklin County' TN" ~20,
    Address == "206 Alabama St 'Franklin County' TN" ~21,
TRUE~ NA
  ))

# create the map of bus 36
# sort the points according to the turn-by-turn order in which students are picked up:
bus_36 <- bus_36 %>% arrange( order )
# create a line from the points:
(bus36_line <- as( as_Spatial(bus_36), 'SpatialLines'))
# make a map of the points and this line:
tm_shape(bus36_line, name = paste0('Bus Line ', bus)) + 
  tm_lines( lwd=2 ) +
  tm_shape( bus_36 ) +
  tm_dots()

