# load libraries


library(tidyverse)
library(googledrive)
library(readxl)


#load data

drive_download("https://docs.google.com/spreadsheets/d/1jXgmUvc1uVJFxSnDV9dYZgEJZjoZ7Bqq/edit?usp=sharing&ouid=112944113011797673714&rtpof=true&sd=true", path = "data/roster_tally.xls", overwrite = TRUE)

bus_df <- read_excel("data/roster_tally.xls")

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

# Data key 
# BV <- Broadview Elementary School
# CM <- Clark Memorial Elementary School
# C  <- Cowan Elementary School
# D  <- Decherd Elementary School
# FC <- Franklin County High School
# H  <- Huntland Schools
# NL <- North Lake Elementary
# NM <- North Middle School
# RC <- Rock Creek Elementary School
# S  <- Sewanee Elementary School
# SM <- South Middle School

