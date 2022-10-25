###### first R session - get the geograpy data (not including zip codes), save as R objects
library(tigris)
library(sf)
options(tigris_use_cache = TRUE)

##### get regions we care about, and save them as R objects

## all of WA state
WA_state <- states(year=2020) %>% 
    filter(NAME=="Washington")
save(WA_state, file="zip_to_districts_Robjects/WA_state.rda")
# load("zip_to_districts_Robjects/WA_state.rda")

WA_counties <- counties(year=2020, state="WA")
save(WA_counties, file="zip_to_districts_Robjects/WA_counties.rda")
King_county <- WA_counties %>% filter(NAME=="King")

WA_state_stateLegDists <- state_legislative_districts(year=2020, state="WA")
save(WA_state_stateLegDists, file="zip_to_districts_Robjects/WA_state_stateLegDists.rda")

WA_state_congDists <- congressional_districts(year=2020, state="WA")
save(WA_state_congDists, file="zip_to_districts_Robjects/WA_state_congDists.rda")
# 
# ### use cong districts (smallish object) as an exercise in understanding overlap code
# all_congDists <- congressional_districts(year=2020)
# 
# ## get WA state dirs directly, using ID:
# WA_state_congDists_2 <- all_congDists %>% 
#     filter(STATEFP == WA_state$STATEFP)
# identical(WA_state_congDists$geometry,WA_state_congDists_2$geometry)
# 
# ## or via st_intersection, we now have 27 columns, and geometry is not identical
# WA_state_congDists_3 <- all_congDists %>% 
#     st_intersection(WA_state)
# identical(WA_state_congDists$geometry,WA_state_congDists_3$geometry)
# 
# # yes, this does subset and return identical geometry
# WA_state_congDists_4 <- all_congDists[ st_contains(WA_state, all_congDists)[[1]] ,]
# identical(WA_state_congDists$geometry,WA_state_congDists_4$geometry)


###### first R session - get the zip code data , save as R objects
library(tigris)
library(sf)
options(tigris_use_cache = TRUE)

## load WA state - saved it earlier
load("zip_to_districts_Robjects/WA_state.rda")

## zip codes in WA state: 

# we have to start by getting ALL US zip codes (cannot specify state="WA" for 2020 for some reason, although you can for other years)
# there are 33791 in total
all_zipCodes <-  zctas(year=2020) 

# this has 647 rows, 10 columns just like the original all_zipCodes object, and I got no warnings
# (google says Washington has a total of 592 active zip codes, so maybe I have a few extra - they may be the ones on the WA/OR boundary, for example, or maybe they're 'inactive' zip codes
WA_state_zipCodes <- all_zipCodes[ st_intersects(WA_state, all_zipCodes)[[1]] ,]
## using other functions instead of st_intersects:
# st_contains gets 542 zip codes
# st_overlaps gets 110 zip codes
# st_touches gets 0 zip codes (either way around)

save(WA_state_zipCodes, file="zip_to_districts_Robjects/WA_state_zipCodes.rda")

##### START A NEW R SESSION!

###### third R session - look at zip code - congDists overlaps, st_intersects method.  Save full R object and plain zip-congDist table

library(tigris)
library(sf)
library(tidyverse)
options(tigris_use_cache = TRUE)

# load data
load("zip_to_districts_Robjects/WA_state_zipCodes.rda")
load("zip_to_districts_Robjects/WA_state_congDists.rda")

# this takes 1.7 seconds
system.time(zipCodes_by_congDist_intersect <- st_join(WA_state_zipCodes, 
                             WA_state_congDists, 
                             join = st_intersects, 
                             left=FALSE))
# turn that into a tibble
zipCodes_by_congDist_intersect_plain <- zipCodes_by_congDist_intersect %>%
    select(ZCTA5CE20,NAMELSAD) %>%
    as_tibble() %>%
    select(-geometry) %>% 
    arrange(NAMELSAD) %>% 
    rename(congressional_district=NAMELSAD) %>% 
    rename(zip_code=ZCTA5CE20)

save(zipCodes_by_congDist_intersect, file="zip_to_districts_Robjects/zipCodes_by_congDist_intersect.rda")
save(zipCodes_by_congDist_intersect_plain, file="zip_to_districts_Robjects/zipCodes_by_congDist_intersect_plain.rda")


##### START A NEW R SESSION!

###### fourth R session - look at zip code - congDists overlaps, st_within method.  Save full R object and plain zip-congDist table

library(tigris)
library(sf)
library(tidyverse)
options(tigris_use_cache = TRUE)

# load data
load("zip_to_districts_Robjects/WA_state_zipCodes.rda")
load("zip_to_districts_Robjects/WA_state_congDists.rda")

# this takes 1.7 seconds
system.time(zipCodes_by_congDist_within <- st_join(WA_state_zipCodes, 
                                                      WA_state_congDists, 
                                                      join = st_within, 
                                                      left=FALSE))
# turn that into a tibble
zipCodes_by_congDist_within_plain <- zipCodes_by_congDist_within %>%
    select(ZCTA5CE20,NAMELSAD) %>%
    as_tibble() %>%
    select(-geometry) %>% 
    arrange(NAMELSAD) %>% 
    rename(congressional_district=NAMELSAD) %>% 
    rename(zip_code=ZCTA5CE20)

save(zipCodes_by_congDist_within, file="zip_to_districts_Robjects/zipCodes_by_congDist_within.rda")
save(zipCodes_by_congDist_within_plain, file="zip_to_districts_Robjects/zipCodes_by_congDist_within_plain.rda")


##### 
###### fourth R session - look at zip code - congDists overlaps, st_intersects method with largest=TRUE option.  Save full R object and plain zip-congDist table

library(tigris)
library(sf)
library(tidyverse)
options(tigris_use_cache = TRUE)

# load data
load("zip_to_districts_Robjects/WA_state_zipCodes.rda")
load("zip_to_districts_Robjects/WA_state_congDists.rda")

system.time(zipCodes_by_CongDist_intersectLargest <- st_join(WA_state_zipCodes, 
                                                 WA_state_congDists, 
                                                 join = st_intersects, 
                                                 largest=TRUE,
                                                 left=FALSE,
                                                 snap=s2::s2_snap_precision(1e-16)))
#Warning message:
# attribute variables are assumed to be spatially constant throughout all geometries 

## the snap=s2::s2_snap_precision(1e-16) is to avoid an error I got without it when largest=TRUE, which is explained [here](https://github.com/r-spatial/s2/issues/144)

# turn that into a tibble
zipCodes_by_CongDist_intersectLargest_plain <- zipCodes_by_CongDist_intersectLargest %>%
    select(ZCTA5CE20,NAMELSAD) %>%
    as_tibble() %>%
    select(-geometry) %>% 
    arrange(NAMELSAD) %>% 
    rename(congressional_district=NAMELSAD) %>% 
    rename(zip_code=ZCTA5CE20)

save(zipCodes_by_CongDist_intersectLargest, file="zip_to_districts_Robjects/zipCodes_by_CongDist_intersectLargest.rda")
save(zipCodes_by_CongDist_intersectLargest_plain, file="zip_to_districts_Robjects/zipCodes_by_CongDist_intersectLargest_plain.rda")



###### fifth R session - try at zip code - LD overlaps, st_intersects method  Save full R object and plain zip-congDist table

library(tigris)
library(sf)
library(tidyverse)
options(tigris_use_cache = TRUE)

# load data
load("zip_to_districts_Robjects/WA_state_zipCodes.rda")
load("zip_to_districts_Robjects/WA_state_stateLegDists.rda")

# took 1.9s
system.time(zipCodes_by_stateLD_intersect <- st_join(WA_state_zipCodes, 
                                                            WA_state_stateLegDists, 
                                                            join = st_intersects, 
                                                            left=FALSE))


# turn that into a tibble
zipCodes_by_stateLD_intersect_plain <- zipCodes_by_stateLD_intersect %>%
    select(ZCTA5CE20,NAMELSAD) %>%
    as_tibble() %>%
    select(-geometry) %>% 
    arrange(NAMELSAD) %>% 
    rename(congressional_district=NAMELSAD) %>% 
    rename(zip_code=ZCTA5CE20)

save(zipCodes_by_stateLD_intersect, file="zip_to_districts_Robjects/zipCodes_by_stateLD_intersect.rda")
save(zipCodes_by_stateLD_intersect_plain, file="zip_to_districts_Robjects/zipCodes_by_stateLD_intersect_plain.rda")


###### sixth R session - try at zip code - LD overlaps, st_intersects method with largest=TRUE option.  Save full R object and plain zip-congDist table

library(tigris)
library(sf)
library(tidyverse)
options(tigris_use_cache = TRUE)

# load data
load("zip_to_districts_Robjects/WA_state_zipCodes.rda")
load("zip_to_districts_Robjects/WA_state_stateLegDists.rda")

# took 100sec
system.time(zipCodes_by_stateLD_intersectLargest <- st_join(WA_state_zipCodes, 
                                                            WA_state_stateLegDists, 
                                                             join = st_intersects, 
                                                             largest=TRUE,
                                                             left=FALSE,
                                                             snap=s2::s2_snap_precision(1e-16)))

#Warning message:
# attribute variables are assumed to be spatially constant throughout all geometries 

## the snap=s2::s2_snap_precision(1e-16) is to avoid an error I got without it when largest=TRUE, which is explained [here](https://github.com/r-spatial/s2/issues/144)

# turn that into a tibble
zipCodes_by_stateLD_intersectLargest_plain <- zipCodes_by_stateLD_intersectLargest %>%
    select(ZCTA5CE20,NAMELSAD) %>%
    as_tibble() %>%
    select(-geometry) %>% 
    arrange(NAMELSAD) %>% 
    rename(congressional_district=NAMELSAD) %>% 
    rename(zip_code=ZCTA5CE20)

save(zipCodes_by_stateLD_intersectLargest, file="zip_to_districts_Robjects/zipCodes_by_stateLD_intersectLargest.rda")
save(zipCodes_by_stateLD_intersectLargest_plain, file="zip_to_districts_Robjects/zipCodes_by_stateLD_intersectLargest_plain.rda")
