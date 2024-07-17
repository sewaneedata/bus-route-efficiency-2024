# Bus-Route-Efficiency-2024

## Description of the Files

1. `addresses.R` - This takes the Google sheet addresses, geocodes them using the Google Maps API, and saves them in the `bus_gis.RData` file. This script requires a paid Google Maps API key and takes a while to run. `bus_gis.RData` has the latitudes and longitudes required for the final product. Since the script takes a long time to run, the `bus_gis.RData` file (generated on 07/17/2024) can be downloaded via [this link](https://drive.google.com/file/d/1kl8nvWYXfcdH9jsDdYwMavAX3lSkdOnm/view?usp=sharing) if you have access.
2. `franklin_county.rds` - This has the geodata to draw the border of Franklin County in maps. * This is the only part that has to be downloaded outside of the repository. The link to `franklin_county.rds` can be found [here](https://drive.google.com/file/d/1FceRqZVVa3RhJmYRs1GRqeL69NRMsQ-h/view?usp=sharing). 
3. `bus_functions.R`- This creates functions that are used in `get_data.R` and in `app.R`
4. `get_data.R` - This file generates the data files `bus_default_data.rds` and `bus_routes.rds`, which contain whether or not the bus information is valid by checking for a longitude, latitude, and address; Google Maps address; location type; and geolocation for every address.
5. `app.R` - This script generates the BUS ROUTES OF FRANKLIN COUNTY SCHOOLS Shiny dashboard. This dashboard handles dynamic data updates, route selection, issue identification, and visualization, providing an interactive and efficient tool for managing school bus routes. 
## Setup Before Running the Dashboard

1. Install `RStudio` (Learn how to do that [here](https://github.com/git-guides/install-git)).
2. Open `Rstudio`
3. Press the file button on the top left, and then click new project.
4. Then press Version Control.
5. Then press Git.
6. Now in Github find the repository and go to the code tab.
7. Press the green code button and copy the URL.
8. Paste the URL in the repository URL selection.
9. You can either leave the Project directory name blank to auto fill or add whatever you want to name it then press create project.
10. Open the `neededpackages.R` then run it. To run a script, click the source button in the top right of the file viewer window.
11. Open `addresses.R`.
12. Enter a google api key, which you can get [here](https://developers.google.com/maps/documentation/geocoding/get-api-key), where it says "YOUR GOOGLE MAPS API KEY GOES HERE!" on line 17, and run it.
13. Download `franklin_county.rds` and put it in a folder called `data` in the same folder as the scripts.
14. Then open `bus_funtions.R` and run it.
15. Then open `get_data.R` and run it.
  
## How to Run the Dashboard

1. Open the dashboard file (`dashboard/app.R`).
2. Then press Run App.

