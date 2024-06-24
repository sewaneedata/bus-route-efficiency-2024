# load libraries

library(tidyverse)
library(gsheet)

#load data

bus_df<- gsheet::gsheet2tbl("https://docs.google.com/spreadsheets/d/1jXgmUvc1uVJFxSnDV9dYZgEJZjoZ7Bqq/edit?usp=sharing&ouid=103805330628828323032&rtpof=true&sd=true")