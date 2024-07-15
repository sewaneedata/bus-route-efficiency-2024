# bus_routes dashboard

library(shiny)
library(DT)
library(dplyr)
library(ggplot2)
library(gsheet)

# practice url
# https://docs.google.com/spreadsheets/d/11ak0g0lD4wstiQfWhGnYeVxSZlL01Bw5VEpg0CpLhTM/edit?usp=sharing'

# setwd(dirname(rstudioapi::getActiveDocumentContext()$path))


if(FALSE){
  library(swfscDAS)
  library(gsheet)

  # Prep data ==================================================================

  # Load  bus route data
  url <- 'https://docs.google.com/spreadsheets/d/12Qj9yy1YgqnOWQk3qDCRP9LjsEQUckdJz9DPwogGDSM/edit?usp=sharing'
  bus <- gsheet::gsheet2tbl(url)
  # Make column for joining
  bus$address_simple <- bus$Address

  # Load spatial data
  load('bus_gis.RData')
  bus_points <- sfheaders::sf_to_df(bus_points, fill=TRUE)
  # Make column for joining
  bus_points$address_simple <- gsub(" 'Franklin County' TN", "", bus_points$address)

  # Join datasets
  mr <- left_join(bus, bus_points, by='address_simple')
  mr <- mr %>% select(address = address_simple,
                      route = Bus,
                      am = AM,
                      pm = PM,
                      x, y)

  mr %>% head
  bus_provided <- mr
  save(bus_provided, file='bus_routes_provided.rds')


  # Helper function ============================================================

  route_distance_crow <- function(dataset){
    # dataset needs columns named route, x (lon), y (lat), & order

    mrs <-
      dataset %>%
      group_by(route) %>%
      arrange(order) %>%
      mutate(next_x = lead(x),
             next_y = lead(y)) %>%
      rowwise() %>%
      mutate(km = swfscDAS::distance_greatcircle(lat1 = y,
                                                 lon1 = x,
                                                 lat2 = next_y,
                                                 lon2 = next_x)) %>%
      ungroup()

    # Get best route
    mrs_total <-
      mrs %>%
      group_by(route) %>%
      summarize(km_tot = sum(km, na.rm=TRUE))

    return(mrs_total)
  }

  # test it
  mrtest <-
    mr %>%
    group_by(route) %>%
    mutate(order = 1:n())

  route_distance_crow(mrtest)


  # Helper function ============================================================
  # this function uses an iterative routine to estimate the most-efficient possible order
  # to stop at households along a route
  # (as the crow flies, not driving distance)
  #
  find_best_route <- function(dataset, B = 10000){

    # rename dataset
    mrii <- dataset

    # Replicate the dataset many times,
    # each time shuffling the order of pick up / drop off
    B <- B
    iterations <- rep(1:B, each=nrow(mrii))
    iterations %>% head(100)
    new_order <-
      sapply(1:B,
             function(x){sample(1:nrow(mrii),
                                size=nrow(mrii),
                                replace=FALSE)}) %>%
      as.vector
    mrs <- mrii[new_order, ]
    mrs$iteration = iterations

    # Get distance between points in each iteration (as crow flies)
    mrs <-
      mrs %>%
      group_by(iteration) %>%
      mutate(order = 1:n()) %>%
      mutate(next_x = lead(x),
             next_y = lead(y)) %>%
      rowwise() %>%
      mutate(km = swfscDAS::distance_greatcircle(lat1 = y,
                                                 lon1 = x,
                                                 lat2 = next_y,
                                                 lon2 = next_x)) %>%
      ungroup()

    # Find most efficient route (as crow flies)
    best_iteration <-
      mrs %>%
      group_by(iteration) %>%
      summarize(km_route = sum(km, na.rm=TRUE)) %>%
      arrange(km_route) %>%
      head(1)

    best_iteration

    # Get best route
    mrs_best <-
      mrs %>%
      filter(iteration == best_iteration$iteration) %>%
      mutate(km_route = best_iteration$km_route)

    return(mrs_best)
  }


  # Loop through each bus route ================================================
  # and estimate best route

  # Stage dataframe for results
  best_routes <- data.frame()

  (routes <- mr$route %>% unique %>% sort)
  ri = 1
  for(ri in 1:length(routes)){
    message('--- Bus route ', ri)

    # Filter to this bus route
    (routi <- routes[ri])
    mri <- mr %>% filter(route == routi)
    mri$am <- tidyr::replace_na(mri$am, 1)
    mri$pm <- tidyr::replace_na(mri$pm, 1)

    # Loop through each time of day
    ti = 1
    time_ops <- c('am', 'pm')
    for(ti in 1:length(time_ops)){
      (timi <- time_ops[ti])
      message('--- --- time of day: ', toupper(timi))

      # Filter to time of day
      if(timi == 'am'){
        mrii <- mri %>% filter(am == 1)
      }else{
        mrii <- mri %>% filter(is.na(pm) | pm == 1)
      }
      mrii %>% head
      mrii %>% nrow

      # Add ID
      mrii$ampm <- timi
      (mrii$id <- paste0(routi,'-',timi))

      # Calculate best route as the crow flies (10,000 iterations)
      message('--- --- computing best route ...')
      besti <- find_best_route(mrii, B = 10000)
      besti
      message('--- --- most efficient distance (in km, as crow flies) = ',
              round(besti$km_route[1], 1))
      message('')

      # Add to results dataset
      best_routes <- rbind(best_routes, besti)
    }
  }

  # Check out results ==========================================================

  best_routes %>% nrow
  best_routes %>% head

  # Summarize results

  best_routes %>%
    group_by(id) %>%
    summarize(km_total = km_route[1],
              students = n()) %>%
    arrange(desc(km_total)) %>%
    View

}


################################################################################
# UI

ui <- fluidPage(

  textInput('url_bus',
            value = 'https://docs.google.com/spreadsheets/d/11ak0g0lD4wstiQfWhGnYeVxSZlL01Bw5VEpg0CpLhTM/edit?usp=sharing',
            label = 'Provide the link for bus routes'),

  textInput('url_addresses',
            label = 'Provide the link for addresses'),


  DT::dataTableOutput("mytable1")


)


################################################################################
# SERVER

server <- function(input, output) {

  output$mytable1 <- DT::renderDataTable({
    df <- gsheet2tbl(input$url_bus)
    Sys.sleep(1)
    DT::datatable(df)
  })

}

################################################################################
# LAUNCH APP

shinyApp(ui = ui, server = server)


