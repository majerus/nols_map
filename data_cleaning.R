# load R packages
library(tidyverse)
library(leaflet)
library(htmltools)
library(datapasta)
library(tidygeocoder)

# NOLS CAMPUS LOCATIONS DATASET ----

# create data frame of all NOLS campus locations in the United States
nols <- tibble::tribble(
                     ~name,                                      ~address,
               "NOLS Alaska",          "5805 N. Farm Loop Palmer, AK 99645",
            "NOLS Northeast",       "730 State Route 86 Gabriels, NY 12939",
    "NOLS Pacific Northwest",    "20950 Bulson Road Mount Vernon, WA 98274",
           "NOLS River Base",         "3101 E. 2500 South Vernal, UT 84078",
       "NOLS Rocky Mountain",         "502 Lincoln Street Lander, WY 82520",
            "NOLS Southwest",   "2751 North Soldier Trail Tucson, AZ 85749",
         "NOLS Teton Valley", "1690 East 2000 South South Driggs, ID 83422",
    "NOLS Three Peaks Ranch",           "534 Highway 353 Boulder, WY 82923"
    )

# geocode NOLS campus locations
nols <- 
  nols %>%
  geocode(address = address, method = "arcgis", lat = latitude , long = longitude)

# create csv with geocoded NOLS campus locations
write_csv(nols, "nols_locations_geocoded.csv")

# PUBLIC US HIGH SCHOOLS DATASET ----

# load data set of US public high schools from
# https://public.opendatasoft.com/explore/dataset/us-public-schools/table/
public <- readxl::read_xlsx("us-public-schools.xlsx")

# clean column names
public <- janitor::clean_names(public)

# clean public high school data
public <- 
  public %>% 
  select(name, address, city, state, zip, telephone, enrollment, st_grade, end_grade, latitude, longitude) %>% 
  mutate(latitude = as.numeric(latitude),
         longitude = as.numeric(longitude),
         address = str_to_title(address),
         name = str_to_title(name),
         city = str_to_title(city),
         # create type variable for filtering in web application
         type = "Public Secondary",
         # create text for popup in web application
         text = paste(name, "<br>", 
                      type, "<br>", 
                      "Enrollment:", enrollment, "<br>",
                      "Grades:", st_grade, "to", end_grade, "<br>",
                      address, "<br>",
                      city, state, zip, "<br>", 
                      telephone),
         address = paste(address, city, state, zip)) %>%
  select(-city, -state, -zip) %>% 
  filter(end_grade %in% c("12", "UG")) 


# PRIVATE US HIGH SCHOOLS DATASET ----

# load data set of US private high schools from
# https://public.opendatasoft.com/explore/dataset/us-private-schools/table/
private <- readxl::read_xlsx("us-private-schools.xlsx")

# clean column names
private <- janitor::clean_names(private)

# clean private high school data
private <- 
  private %>% 
  filter(level > 1) %>% 
  select(name, address, city, state, zip, telephone, enrollment, st_grade, end_grade, latitude, longitude) %>% 
  mutate(latitude = as.numeric(latitude),
         longitude = as.numeric(longitude),
         address = str_to_title(address),
         name = str_to_title(name),
         city = str_to_title(city),
         # create type variable for filtering in web application
         type = "Private Secondary",
         # create text for popup in web application
         text = paste(name, "<br>", 
                      type, "<br>", 
                      "Enrollment:", enrollment, "<br>",
                      "Grades:", st_grade, "to", end_grade, "<br>",
                      address, "<br>",
                      city, state, zip, "<br>", 
                      telephone),
         address = paste(address, city, state, zip)) %>%
  select(-city, -state, -zip)



#  US COLLEGES AND UNIVERSITIES DATASET ----

# load data set of US private high schools from
# https://public.opendatasoft.com/explore/dataset/us-colleges-and-universities/table/
colleges <- readxl::read_xlsx("nols-map/us-colleges-and-universities.xlsx")

# clean column names
colleges <- janitor::clean_names(colleges)

# clean colleges data
colleges <- 
colleges %>% 
  # create type variable for filtering in web application
  mutate(sector = recode(sector,
                         '0' = 'Administrative Unit', 
                         '1' = 'Public 4-year College',
                         '2' = 'Private nonprofit 4-year College',
                         '3' = 'Private for-profit 4-year or above',
                         '4' = 'Public 2-Year',
                         '5' = 'Private nonprofit 2-year',
                         '6' = 'Private for-profit 2-year',
                         '7' = 'Public less-than-2-year',
                         '8' = 'Private nonprofit less-than-2-year',
                         '9' = 'Private for-profit less-than-2-year',
                         '99'= 'Sector unknown')) %>% 
  filter(sector %in% c('Public 4-year College', 'Private nonprofit 4-year College')) %>% 
  filter(close_date == -2) %>% 
  select(-type) %>% 
  rename(type = sector,
         enrollment = tot_enroll) %>% 
  mutate(latitude = as.numeric(latitude),
       longitude = as.numeric(longitude),
       address = str_to_title(address),
       name = str_to_title(name),
       city = str_to_title(city),
       # create text for popup in web application
       text = paste(name, "<br>", 
                    type, "<br>", 
                    "Enrollment:", enrollment, "<br>",
                    address, "<br>",
                    city, state, zip, "<br>", 
                    telephone),
       address = paste(address, city, state, zip)) %>%
    select(name, address, telephone, enrollment,  latitude, longitude, type, text)
  

# JOIN DATASETS ----

# bind public high school data, private high school data, and college data together
df <- bind_rows(public, private, colleges)

# remove any type of school with enrollment of 0
df <- df %>%  filter(enrollment > 0)

# write out combinted data set to csv in web application folder
write_csv(df, "nols-map/schools.csv")













