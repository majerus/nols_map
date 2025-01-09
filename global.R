# load all packages need for web application
library(shiny)
library(shinyjs)
library(leaflet)
library(tidyverse)
library(DT)

# read in NOLS US campus location data
nols <- read_csv("nols_locations_geocoded.csv")

# read in data set of high schools and colleges in US
schools <- read_csv("schools.csv")

# create base map for leaflet
m <- 
  leaflet() %>% 
  addTiles() %>% 
  # set default map view at center point of US
  setView(lng = -86.6836, lat = 33.64566, zoom = 4)

# create color palette for schools based on type
pal <- colorFactor(c("#810f7c", "#0868ac", "#b30000", "#993404"), 
                   levels = c("Public Secondary", "Private Secondary", 
                              'Public 4-year College', 'Private nonprofit 4-year College'))

