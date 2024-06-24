# load libraries

library(tidyverse)
library(gsheet)

#load data

bus_df<- gsheet::gsheet2tbl("https://docs.google.com/spreadsheets/d/1jXgmUvc1uVJFxSnDV9dYZgEJZjoZ7Bqq/edit?usp=sharing&ouid=103805330628828323032&rtpof=true&sd=true")

# Number of columns
ncol(bus_df)

# Number of rows
nrow(bus_df)

# Name of variables
names(bus_df)

#First rows 
head(bus_df)

#Last rows
tail(bus_df)
