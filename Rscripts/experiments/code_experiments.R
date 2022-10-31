
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


########## older code where I looked at congressional districts not legislative districts
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


```{r}
# 
# library(ggplot2)
# 
# ggplot(WA_state_proj) +
#   geom_sf( ) 
# 
# 
# +
#   coord_sf(xlim = st_coordinates(bbox_new)[c(1,2),1], # min & max of x values
#            ylim = st_coordinates(bbox_new)[c(2,3),2]) + # min & max of y values
#   ggtitle('a ggplot2 title')

```

