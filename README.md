<<<<<<< HEAD
# bus-route-efficiency-2024

##Setup

1. Install Rstudio (Learn how to do that [here](https://github.com/git-guides/install-git)).
2. Create a file that will hold all the files for this projector 
2. Press the file button on the top left and then click new project
3. Then press Version Control
4. Then hit Git
5. Now in Github find the repository and go to the code tab
6. Press the green code button and copy the URL
7. Paste the URL in the repository URL selection
8. You can either leave the Project directory name blank to auto fill or add whatever you want to name it then press create project
9. Open the neededpackages.R then run it
10. Open addresses.R
11. Enter a google api key where it says YOUR GOOGLE MAPS API KEY GOES HERE! on line 17, and run it (you can get a geocoding API [here](https://developers.google.com/maps/documentation/geocoding/get-api-key))
12. Download franklin_county.rds and put it in a file called data that is in the file that is holding all the files for this.
13.Then open bus_funtions.R and run it
14.Then open get_data.R and run it
  
## How to Run the App

1. Open the file dashboard
2. Open app.R
3. Set your working directory to the Dashboard folder within the repository folder
4. Then press Run App

## Description of the Files

1. addresses.R - This takes the google sheet addresses and adds the address found on the google map API into the data set. Running this will take sometime because it takes time to access the API and grab the geo locations.
2. franklin_county.rds - This has the geodata to draw the border of franklin county in maps
3. bus_gis.RData - This 
4. bus_functions.R- This gives functions that can be called upon in the get_data and in app.R
5. get_data.R - helping files similar to bus_data.R so that it prevents multiple things being called
6. bus_default_data.rds - This loads and holds the url that is inputed in the url and if no url is put in it is whatever the values is equal to
7. bus_routes.rds - this has the bus route information like the kids grade, bus number, house address, longitude and latitude, and reported miles. 
8. app.R - This is where the dashboard with the user input and server is made. 
=======
# Bus-Route-Efficiency-2024

## Setup

1. Install `RStudio` (Learn how to do that [here](https://github.com/git-guides/install-git)).
2. Create a folder that will hold all the files for this project.
2. Open `Rstudio` and click the little icon with a r in a cube on the top left.
3. Then press Version Control.
4. Then press Git.
5. Now in Github find the repository and go to the code tab.
6. Press the green code button and copy the URL.
7. Paste the URL in the repository URL selection.
8. You can either leave the Project directory name blank to auto fill or add whatever you want to name it then press create project.
9. Open the `neededpackages.R` then run it.
10. Open `addresses.R`.
11. Enter a google api key where it says YOUR GOOGLE MAPS API KEY GOES HERE! on line 17, and run it (you can get a geocoding API [here](https://developers.google.com/maps/documentation/geocoding/get-api-key)).
12. Download `franklin_county.rds` and put it in a file called data that is in the file that is holding all the files for this.
13.Then open `bus_funtions.R` and run it.
14.Then open `get_data.R` and run it.
  
## How to Run the App

1. Open the file dashboard.
2. Open `app.R`.
3. Set your working directory to the Dashboard folder within the repository folder.
4. Then press Run App.

## Description of the Files

1. `addresses.R` - This takes the google sheet addresses and adds the address found on the google map API into the data set. Running this will take sometime because it takes time to access the API and grab the geo locations.
2. `franklin_county.rds` - This has the geodata to draw the border of franklin county in maps
3. `bus_gis.RData` - This 
4. `bus_functions.R`- This gives functions that can be called upon in the get_data and in app.R
5. `get_data.R` - helping files similar to bus_data.R so that it prevents multiple things being called
6. `bus_default_data.rds` - This loads and holds the url that is inputed in the url and if no url is put in it is whatever the values is equal to
7. `bus_routes.rds` - this has the bus route information like the kids grade, bus number, house address, longitude and latitude, and reported miles. 
8. `app.R` - This is where the dashboard with the user input and server is made. 

## Notes
1. The data used for this comes from the URL entered on the dashboard. This will be the data in the files within the data folder, excluding `franklin_county.rds.`  



>>>>>>> c92264666d1f44d695ab818f4d3ce8322817ce23

