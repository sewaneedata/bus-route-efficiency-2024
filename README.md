# Bus-Route-Efficiency-2024

## Description of the Files

1. `addresses.R` - This takes the google sheet addresses, geocodes them using the Google Maps API, and saves them in the `bus_gis.RData` file. This script requires a paid Google Maps API key and takes a while to run.
2. `franklin_county.rds` - This has the geodata to draw the border of franklin county in maps.
3. `bus_gis.RData` - This is the dataframe that has the latitudes and longitudes.
4. `bus_functions.R`- This creates functions that are used in `get_data.R` and in `app.R`
5. `get_data.R` - This file generates the data files `bus_default_data.rds` and `bus_routes.rds`, which contain whether or not the bus information is valid by checking for a longitude, latitude, and the address; google maps address; location type; and geo location for every address.
6. `app.R` - This is where the dashboard with the user input and server is made. 

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

## Notes
1. The data used for this comes from the URL entered on the dashboard. This will be the data in the files within the data folder, excluding `franklin_county.rds.`  
