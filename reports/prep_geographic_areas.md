prep geographic areas
================
Janet Young
2022-10-30

Goals: 1. obtain geography info for various geographic regions: - WA
state  
- zip codes  
- legislative districts (state level) = “LD” - congressional districts
(federal)

2.  project coordinates for each set of regions into a more suitable
    coordinate system for our region (“NAD83(2011) / Washington North”,
    ID=6596). Code seems to behave better with this system, especially
    when trying to use ‘buffer’ functions to shrink areas a little bit.

We obtain state, county, LD and congressional districts using simple
tigris functions:

``` r
WA_state <- states(year=2020) %>% 
    filter(NAME=="Washington")
WA_counties <- counties(year=2020, state="WA")
WA_stateLegDists <- state_legislative_districts(year=2020, state="WA")
# add a short name to help plots
WA_stateLegDists$shortName = gsub("State Senate District ","LD_",
                                  WA_stateLegDists$NAMELSAD)
WA_congDists <- congressional_districts(year=2020, state="WA")
WA_congDists$shortName = gsub("Congressional District ","CD_",
                                  WA_congDists$NAMELSAD)
```

For some reason the `state="WA"` option does not work for zip codes from
the 2020 census. So we start by getting all zip codes, and use the
`st_intersects()` function to get only those that intersect with WA
state.

``` r
all_zipCodes <-  zctas(year=2020) # there are 33791 in total

# this has 647 rows, 10 columns just like the original all_zipCodes object, and I got no warnings
# (google says Washington has a total of 592 active zip codes. I definitely have a few extra - I know some are zip codes in Idaho/Oregon that just touch WA but don't actually overlap. Maybe some are 'inactive' zip codes
WA_state_zipCodes <- all_zipCodes[ st_intersects(WA_state, all_zipCodes)[[1]] ,]

## using other functions instead of st_intersects:
# st_contains gets 542 zip codes
# st_overlaps gets 110 zip codes
# st_touches gets 0 zip codes (either way around)
```

Now we project the coordinates to the “NAD83(2011) / Washington North”
system, ID=6596 (defined at the top of this script). We use the
`st_transform()` function, but I’ll wrap it in a tiny function to help
make sure I’m consistent if I ever decide to change the coordinate
system we’re projecting to.

``` r
projectCoords <- function(regions, use_crs = chosenCoordReferenceSystem)  {
    projected <- st_transform(regions, crs = use_crs)
    return(projected)
}
WA_state_proj <- projectCoords(WA_state)
WA_counties_proj <- projectCoords(WA_counties)
WA_stateLegDists_proj <- projectCoords(WA_stateLegDists)
WA_congDists_proj <- projectCoords(WA_congDists)
WA_state_zipCodes_proj <- projectCoords(WA_state_zipCodes)
```

Get a couple of example regions we might use later - King county, and
LD1:

``` r
King_county_proj <- WA_counties_proj %>% filter(NAME=="King")
LD1_proj <- WA_stateLegDists_proj %>% filter(shortName=="LD_1")
```

Now we ‘shrink’ the boundaries of each LD (or congressional district),
by 1km. This will give us better LD-to-zip mappings

``` r
WA_stateLegDists_proj_shrink1km <- st_buffer(WA_stateLegDists_proj, dist= -1000 )
WA_congDists_proj_shrink1km <- st_buffer(WA_congDists_proj, dist= -1000 )
```

Define a smaller region (a bounding box) to help us zoom in when we make
plots. To help figure that out, first I want to know, in the projected
coordinate system, what are the outermost boundary coordinates of WA
state? (“bounding box”)

``` r
st_bbox(WA_state_proj) 
```

    ##      xmin      ymin      xmax      ymax 
    ##  201525.6 -160895.9  803525.7  229158.2

And what are the the outermost boundary coordinates of LD1? (we’re using
this as an example LD to test the code)

``` r
st_bbox(LD1_proj) 
```

    ##      xmin      ymin      xmax      ymax 
    ## 388768.36  77357.27 410832.65  98421.95

Use LD1 coordinates to choose an area to help me zoom in on plots to see
what’s going on (I followed the example code from `?st_bbox` . Looks
like they do it by specifying x/y coordinates of two points at opposite
corners of the box we want to define

``` r
exampleRegionForPlots = st_sf(id = 1:2, 
                              geom = st_sfc(st_point(c(380000,70000)), 
                                            st_point(c(425000,105000))) , 
                              crs = chosenCoordReferenceSystem)
exampleRegionForPlots_bbox <- st_bbox(exampleRegionForPlots)

# show where that region is
tm_shape(WA_state_proj) +
    tm_borders(col = "black") +
    tm_shape(st_as_sfc(exampleRegionForPlots_bbox)) +
    tm_borders(col = "red") +
    tm_layout(main.title= "WA state showing location of example region (red)")
```

![](/Users/jayoung/Documents/WholeWashington/Whole_WA_data_wrangling_playground/reports/prep_geographic_areas_files/figure-gfm/set%20up%20smaller%20bounding%20box-1.png)<!-- -->

Show the LDs within that example region, as well as the ‘shrunken’
regions (1km within the boundaries of each LD) that we’ll use for
LD-to-zip overlaps

``` r
tm_shape(WA_state_proj, bbox=exampleRegionForPlots_bbox) +
    tm_borders(col = "blue") +
    
    tm_shape(WA_stateLegDists_proj_shrink1km) +
    #tm_borders(col="orange") +
    tm_fill(col="orange", alpha=0.5) +

    tm_shape(WA_stateLegDists_proj) +
    tm_borders(col = "black") +
    tm_text("shortName", size=0.5) +
    tm_shape(st_as_sfc(exampleRegionForPlots_bbox)) +
    tm_borders(col = "red")  +
    
    tm_layout(main.title= "LDs in example region\nOrange = region used for zip code overlap calculation", main.title.size=0.9)
```

![](/Users/jayoung/Documents/WholeWashington/Whole_WA_data_wrangling_playground/reports/prep_geographic_areas_files/figure-gfm/show%20some%20LDs%20and%20the%20region%20we%20are%20using%20for%20zip%20code%20calculations-1.png)<!-- -->

``` r
save(WA_state,file=here("saved_R_objects/WA_state.rda"))

save(WA_counties, file=here("saved_R_objects/WA_counties.rda"))
save(WA_stateLegDists, file=here("saved_R_objects/WA_stateLegDists.rda"))
save(WA_congDists, file=here("saved_R_objects/WA_congDists.rda"))
save(WA_state_zipCodes, file=here("saved_R_objects/WA_state_zipCodes.rda"))

save(WA_state_proj, file=here("saved_R_objects/WA_state_proj.rda"))
save(WA_counties_proj, file=here("saved_R_objects/WA_counties_proj.rda"))
save(WA_stateLegDists_proj, file=here("saved_R_objects/WA_stateLegDists_proj.rda"))
save(WA_congDists_proj, file=here("saved_R_objects/WA_congDists_proj.rda"))
save(WA_state_zipCodes_proj, file=here("saved_R_objects/WA_state_zipCodes_proj.rda"))

save(WA_stateLegDists_proj_shrink1km, file=here("saved_R_objects/WA_stateLegDists_proj_shrink1km.rda"))
save(WA_congDists_proj_shrink1km, file=here("saved_R_objects/WA_congDists_proj_shrink1km.rda"))

save(exampleRegionForPlots, exampleRegionForPlots_bbox,
     King_county_proj, LD1_proj, file=here("saved_R_objects/exampleRegions_proj.rda" ))
```

``` r
##### original coordinate system:
# load("saved_R_objects/WA_state.rda")
# load("saved_R_objects/WA_counties.rda")
# load("saved_R_objects/WA_stateLegDists.rda")
# load("saved_R_objects/WA_congDists.rda")
# load("saved_R_objects/WA_state_zipCodes.rda")

##### projected coords:
# load("saved_R_objects/WA_state_proj.rda")
# load("saved_R_objects/WA_counties_proj.rda")
# load("saved_R_objects/WA_stateLegDists_proj.rda")
# load("saved_R_objects/WA_congDists_proj.rda")
# load("saved_R_objects/WA_state_zipCodes_proj.rda")

##### shrunken
# load("saved_R_objects/WA_stateLegDists_proj_shrink1km.rda")
# load("saved_R_objects/WA_congDists_proj_shrink1km.rda")

##### example regions
# load("saved_R_objects/exampleRegions_proj.rda" )
```

``` r
sessionInfo()
```

    ## R version 4.2.1 (2022-06-23)
    ## Platform: x86_64-apple-darwin17.0 (64-bit)
    ## Running under: macOS Big Sur ... 10.16
    ## 
    ## Matrix products: default
    ## BLAS:   /Library/Frameworks/R.framework/Versions/4.2/Resources/lib/libRblas.0.dylib
    ## LAPACK: /Library/Frameworks/R.framework/Versions/4.2/Resources/lib/libRlapack.dylib
    ## 
    ## locale:
    ## [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
    ## 
    ## attached base packages:
    ## [1] stats     graphics  grDevices utils     datasets  methods   base     
    ## 
    ## other attached packages:
    ##  [1] here_1.0.1      tmap_3.3-3      forcats_0.5.2   stringr_1.4.1  
    ##  [5] dplyr_1.0.10    purrr_0.3.5     readr_2.1.3     tidyr_1.2.1    
    ##  [9] tibble_3.1.8    ggplot2_3.3.6   tidyverse_1.3.2 sf_1.0-8       
    ## [13] tigris_1.6.1   
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] fs_1.5.2            lubridate_1.8.0     RColorBrewer_1.1-3 
    ##  [4] httr_1.4.4          rprojroot_2.0.3     tools_4.2.1        
    ##  [7] backports_1.4.1     utf8_1.2.2          rgdal_1.5-32       
    ## [10] R6_2.5.1            KernSmooth_2.23-20  DBI_1.1.3          
    ## [13] colorspace_2.0-3    raster_3.6-3        withr_2.5.0        
    ## [16] sp_1.5-0            tidyselect_1.2.0    leaflet_2.1.1      
    ## [19] compiler_4.2.1      leafem_0.2.0        cli_3.4.1          
    ## [22] rvest_1.0.3         xml2_1.3.3          scales_1.2.1       
    ## [25] classInt_0.4-8      proxy_0.4-27        rappdirs_0.3.3     
    ## [28] digest_0.6.30       foreign_0.8-83      rmarkdown_2.17     
    ## [31] base64enc_0.1-3     dichromat_2.0-0.1   pkgconfig_2.0.3    
    ## [34] htmltools_0.5.3     highr_0.9           dbplyr_2.2.1       
    ## [37] fastmap_1.1.0       htmlwidgets_1.5.4   rlang_1.0.6        
    ## [40] readxl_1.4.1        rstudioapi_0.14     generics_0.1.3     
    ## [43] jsonlite_1.8.3      crosstalk_1.2.0     googlesheets4_1.0.1
    ## [46] magrittr_2.0.3      s2_1.1.0            Rcpp_1.0.9         
    ## [49] munsell_0.5.0       fansi_1.0.3         abind_1.4-5        
    ## [52] terra_1.6-17        lifecycle_1.0.3     stringi_1.7.8      
    ## [55] leafsync_0.1.0      yaml_2.3.6          tmaptools_3.1-1    
    ## [58] grid_4.2.1          maptools_1.1-5      parallel_4.2.1     
    ## [61] crayon_1.5.2        lattice_0.20-45     haven_2.5.1        
    ## [64] stars_0.5-6         hms_1.1.2           knitr_1.40         
    ## [67] pillar_1.8.1        uuid_1.1-0          codetools_0.2-18   
    ## [70] wk_0.7.0            reprex_2.0.2        XML_3.99-0.11      
    ## [73] glue_1.6.2          evaluate_0.17       modelr_0.1.9       
    ## [76] png_0.1-7           vctrs_0.5.0         tzdb_0.3.0         
    ## [79] cellranger_1.1.0    gtable_0.3.1        assertthat_0.2.1   
    ## [82] xfun_0.34           lwgeom_0.2-9        broom_1.0.1        
    ## [85] e1071_1.7-11        class_7.3-20        googledrive_2.0.0  
    ## [88] viridisLite_0.4.1   gargle_1.2.1        units_0.8-0        
    ## [91] ellipsis_0.3.2
