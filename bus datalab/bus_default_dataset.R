# Process & save default dataset

# source functions
source('bus datalab/bus_functions.R')

# example url
url <- 'https://docs.google.com/spreadsheets/d/1MubRFGO4eIxN1aCQOBe3REAye525-wzqOIzaTYIIg4I/edit?usp=sharing'

# re-process data
bus_data <- bus_data_process(url)

# validity check
bus_data <- bus_validity_check(bus_data)

# check it out
bus_data

# Test map
bus_mapper(bus_data)

# save it
save(bus_data, file = 'bus datalab/bus_default_data.rds')
