zip_to_LD_use_2022_redistricted_boundaries
================
Janet Young
2022-11-02

Goals:

1.  read geography info for REDISTRICTED legislative and congressional
    districts into R

2.  project coordinates for each set of regions into a more suitable
    coordinate system for our region (“NAD83(2011) / Washington North”,
    ID=6596). Code seems to behave better with this system, especially
    when trying to use ‘buffer’ functions to shrink areas a little bit.

3.  get zip code overlaps, save as R objects

4.  make plots and csv file as before

Tell R where to find the WA state redistricting shape files

``` r
redist_data_dirs <- here("downloads/WA_redistricting_commission_2022_Oct30/Final_District_Shapes_2022_NAD_83/Final_District_Shapes_2022")
redist_data_dirs <- list.files(redist_data_dirs, full.names = TRUE)
redist_data_shpFiles <- list.files(redist_data_dirs, pattern=".shp$", full.names = TRUE)

names(redist_data_shpFiles) <-  tolower(sapply(strsplit(redist_data_dirs, "/"), function(x) {
    x[length(x)]
}))
```

Read them in

``` r
CDs_redist <- st_read(redist_data_shpFiles["congessional"])
```

    ## Reading layer `CONG_AMEND_FINAL_GCS_NAD83' from data source 
    ##   `/Users/jayoung/Documents/WholeWashington/Whole_WA_data_wrangling_playground/downloads/WA_redistricting_commission_2022_Oct30/Final_District_Shapes_2022_NAD_83/Final_District_Shapes_2022/Congessional/CONG_AMEND_FINAL_GCS_NAD83.shp' 
    ##   using driver `ESRI Shapefile'
    ## Simple feature collection with 10 features and 6 fields
    ## Geometry type: POLYGON
    ## Dimension:     XY
    ## Bounding box:  xmin: -124.849 ymin: 45.54354 xmax: -116.9161 ymax: 49.00244
    ## Geodetic CRS:  NAD83

``` r
LDs_redist <- st_read(redist_data_shpFiles["legislative"])
```

    ## Reading layer `LEG_AMEND_FINAL_GCS_NAD83' from data source 
    ##   `/Users/jayoung/Documents/WholeWashington/Whole_WA_data_wrangling_playground/downloads/WA_redistricting_commission_2022_Oct30/Final_District_Shapes_2022_NAD_83/Final_District_Shapes_2022/Legislative/LEG_AMEND_FINAL_GCS_NAD83.shp' 
    ##   using driver `ESRI Shapefile'
    ## Simple feature collection with 49 features and 7 fields
    ## Geometry type: POLYGON
    ## Dimension:     XY
    ## Bounding box:  xmin: -124.849 ymin: 45.54354 xmax: -116.9161 ymax: 49.00244
    ## Geodetic CRS:  NAD83

``` r
# add a nicer name for plots
# I checked - the ID, DISTRICT and DISTRICTN columns of CDs_redist (and of LDs_redist) are identical to each other
CDs_redist$districtName <- paste("CD_", CDs_redist$ID, sep="")
LDs_redist$districtName <- paste("LD_", LDs_redist$ID, sep="")
```

Project coordinates to our chosen reference system, better for WA state

``` r
CDs_redist_proj <- projectCoords(CDs_redist)
LDs_redist_proj <- projectCoords(LDs_redist)
```

Now we ‘shrink’ the boundaries of each LD (or congressional district),
by 1km, using the `st_buffer` function. This will give us better
LD-to-zip mappings

``` r
CDs_redist_proj_shrink1km <- st_buffer(CDs_redist_proj, dist= -1000 )
LDs_redist_proj_shrink1km <- st_buffer(LDs_redist_proj, dist= -1000 )
```

Figure out the overlaps between zip codes and LDs. We keep the `sf`
style object with the geographic information, but we also make a plain
tibble.

``` r
zip_LDredist_shrink1km_intersects_proj <- st_join(WA_state_zipCodes_proj, 
                                           LDs_redist_proj_shrink1km, 
                                           join = st_intersects, 
                                           left=FALSE)
zip_LDredist_shrink1km_intersects_proj_plain <- zip_LDredist_shrink1km_intersects_proj %>%
    select(ZCTA5CE20,districtName) %>%
    as_tibble() %>%
    select(-geometry) %>% 
    arrange(ZCTA5CE20) %>% 
    arrange(districtName) %>% 
    rename(zip_code=ZCTA5CE20) 
```

Do the same for congressional districts - get the overlaps between zip
codes and CDs.

``` r
zip_CDredist_shrink1km_intersects_proj <- st_join(WA_state_zipCodes_proj, 
                                           CDs_redist_proj_shrink1km, 
                                           join = st_intersects, 
                                           left=FALSE)
zip_CDredist_shrink1km_intersects_proj_plain <- zip_CDredist_shrink1km_intersects_proj %>%
    select(ZCTA5CE20,districtName) %>%
    as_tibble() %>%
    select(-geometry) %>% 
    arrange(ZCTA5CE20) %>% 
    arrange(districtName) %>% 
    rename(zip_code=ZCTA5CE20) 
```

How many redistricted LDs is each zip code in? boundaries don’t line up,
so some are in \>1.

``` r
zip_LDredist_shrink1km_intersects_proj_plain %>% 
    mutate(zip_code2=factor(zip_code, 
                           levels=zip_WAstate_shrink1km_intersects_proj_plain$zip_code)) %>% 
    count(zip_code2, .drop=FALSE) %>% 
    rename(num_LDs_per_zip=n) %>% 
    count(num_LDs_per_zip) %>% 
    rename(num_zip_codes=n) %>% 
    kable() %>% 
    kable_styling(font_size = 12)
```

<table class="table" style="font-size: 12px; margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:right;">
num_LDs_per_zip
</th>
<th style="text-align:right;">
num_zip_codes
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
9
</td>
</tr>
<tr>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
415
</td>
</tr>
<tr>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
149
</td>
</tr>
<tr>
<td style="text-align:right;">
3
</td>
<td style="text-align:right;">
32
</td>
</tr>
<tr>
<td style="text-align:right;">
4
</td>
<td style="text-align:right;">
1
</td>
</tr>
</tbody>
</table>

Wow - one zip code is now in four LDs. It’s 99301. It includes Pasco -
take a quick look at which LDs it oerlaps:

``` r
zipCodeWith4LDs <- zip_LDredist_shrink1km_intersects_proj_plain %>% 
    count(zip_code, .drop=FALSE) %>% 
    rename(num_LDs_per_zip=n) %>% 
    filter(num_LDs_per_zip==4) %>% 
    select(zip_code) %>% 
    unlist(use.names = FALSE)
zip_LDredist_shrink1km_intersects_proj_plain %>% 
    filter(zip_code == zipCodeWith4LDs) %>% 
    kable() %>% 
    kable_styling()
```

<table class="table" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
zip_code
</th>
<th style="text-align:left;">
districtName
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
99301
</td>
<td style="text-align:left;">
LD_15
</td>
</tr>
<tr>
<td style="text-align:left;">
99301
</td>
<td style="text-align:left;">
LD_16
</td>
</tr>
<tr>
<td style="text-align:left;">
99301
</td>
<td style="text-align:left;">
LD_8
</td>
</tr>
<tr>
<td style="text-align:left;">
99301
</td>
<td style="text-align:left;">
LD_9
</td>
</tr>
</tbody>
</table>

What are the zips that were not assigned to LDs? They might be so small
they got missed because of the 1km shrinkage of the LD boundaries

``` r
zips_without_LDs <- setdiff(zip_WAstate_shrink1km_intersects_proj_plain$zip_code,  
                            zip_LDredist_shrink1km_intersects_proj_plain$zip_code)
zips_without_LDs
```

    ## [1] "98121" "98154" "98164" "98174" "98330" "98544" "98565" "98583" "99020"

``` r
## I checked - there are no zips from outside WA state assigned to LDs 
# setdiff( zip_LDshrink1km_intersects_proj_plain$zip_code, zip_WAstate_shrink1km_intersects_proj_plain$zip_code)
```

How many CDs is each zip code in? boundaries don’t line up, so some are
in \>1.

``` r
zip_CDredist_shrink1km_intersects_proj_plain %>% 
    mutate(zip_code2=factor(zip_code, 
                           levels=zip_WAstate_shrink1km_intersects_proj_plain$zip_code)) %>% 
    count(zip_code2, .drop=FALSE) %>% 
    rename(num_CDs_per_zip=n) %>% 
    count(num_CDs_per_zip) %>% 
    rename(num_zip_codes=n) %>% 
    kable() %>% 
    kable_styling(font_size = 12)
```

<table class="table" style="font-size: 12px; margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:right;">
num_CDs_per_zip
</th>
<th style="text-align:right;">
num_zip_codes
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
5
</td>
</tr>
<tr>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
545
</td>
</tr>
<tr>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
54
</td>
</tr>
<tr>
<td style="text-align:right;">
3
</td>
<td style="text-align:right;">
2
</td>
</tr>
</tbody>
</table>

What are the zips that were not assigned to CDs?

``` r
zips_without_CDs <- setdiff(zip_WAstate_shrink1km_intersects_proj_plain$zip_code,  
                            zip_CDredist_shrink1km_intersects_proj_plain$zip_code)
zips_without_CDs
```

    ## [1] "98154" "98164" "98174" "98330" "98558"

``` r
## I checked - there are no zips from outside WA state assigned to CDs 
## setdiff( zip_CDshrink1km_intersects_proj_plain$zip_code, zip_WAstate_shrink1km_intersects_proj_plain$zip_code)
```

Look at the range of number of zip codes per LD / CD

``` r
numZipsPerLD <- zip_LDredist_shrink1km_intersects_proj_plain %>% 
    count(districtName) %>% 
    rename(num_zips_per_LD=n) %>% 
    summarize(min_zips_per_LD=min(num_zips_per_LD),
              max_zips_per_LD=max(num_zips_per_LD)) %>% 
    t()

numZipsPerCD <- zip_CDredist_shrink1km_intersects_proj_plain %>% 
    count(districtName) %>% 
    rename(num_zips_per_CD=n) %>% 
    summarize(min_zips_per_CD=min(num_zips_per_CD),
              max_zips_per_CD=max(num_zips_per_CD)) %>% 
    t() 

rbind(numZipsPerLD, numZipsPerCD) %>% 
    kable() %>% 
    kable_styling(font_size = 12)
```

<table class="table" style="font-size: 12px; margin-left: auto; margin-right: auto;">
<tbody>
<tr>
<td style="text-align:left;">
min_zips_per_LD
</td>
<td style="text-align:right;">
5
</td>
</tr>
<tr>
<td style="text-align:left;">
max_zips_per_LD
</td>
<td style="text-align:right;">
76
</td>
</tr>
<tr>
<td style="text-align:left;">
min_zips_per_CD
</td>
<td style="text-align:right;">
27
</td>
</tr>
<tr>
<td style="text-align:left;">
max_zips_per_CD
</td>
<td style="text-align:right;">
132
</td>
</tr>
</tbody>
</table>

Now export the LD to zip tibble in a similar format to Kelsey’s google
sheet. Can’t just `pivot_wider()`, because some zips are present more
than once and the columns have different lengths. (or maybe we could if
we messed around a bit) I made a function called `makeWideTable()` (see
`Rscripts/shared_functions.R`) that uses data.frame and a for loop
instead.

``` r
### get LD zip table
LDzip_wide <- zip_LDredist_shrink1km_intersects_proj_plain %>% 
    rename(dist=districtName) %>% 
    makeWideTable(maxZips=numZipsPerLD["max_zips_per_LD",1], 
                  missingZips=zips_without_LDs,
                  saveToFile=here("output_to_share/version3_2022_Nov_redistricting2022_prettier/LDredist2022_zip_codes_uncurated_v3_2022_Nov2.tsv"))

### get CD zip table
CDzip_wide <- zip_CDredist_shrink1km_intersects_proj_plain %>% 
    rename(dist=districtName) %>% 
    makeWideTable(maxZips=numZipsPerCD["max_zips_per_CD",1], 
                  missingZips=zips_without_CDs,
                  saveToFile=here("output_to_share/version3_2022_Nov_redistricting2022_prettier/CDredist2022_zip_codes_uncurated_v3_2022_Nov2.tsv"))
```

now make a plot for each LD, showing the zip codes we assigned to it.

(will be able to modify this function to work on CDs too - need to fix
some column names first)

``` r
plotDistrictAndZipCodes_redist <- function(
        allZipMaps=WA_state_zipCodes_proj,
        allDistrictMaps=LDs_redist_proj,
        oldDistrictMaps=WA_stateLegDists_proj,
        zipToDistrictTbl=NULL,
        district_short_name,
        savePlot=NULL) {
    
    zips_to_plot <- zipToDistrictTbl %>% 
        filter(districtName==district_short_name) %>% 
        select(zip_code) %>% 
        unlist(use.names = FALSE)
    myTitle <- paste(district_short_name, "(2022 in red, pre-2022 in blue)\nand assigned zip codes (uncurated)")
    
    
    zipMapsThisDistrict <- allZipMaps %>% filter(ZCTA5CE20 %in% zips_to_plot)
    thisDistrictMap <- allDistrictMaps %>% filter(districtName==district_short_name)
    thisDistrictMapOld <- oldDistrictMaps %>% filter(shortName==district_short_name)
     
    wholeRegionToPlot <- st_union(st_union(zipMapsThisDistrict),st_union(thisDistrictMap)  )
    wholeRegionToPlot <- st_union(wholeRegionToPlot,st_union(thisDistrictMapOld) ) 
    p <- tm_shape(zipMapsThisDistrict, bbox=st_bbox(wholeRegionToPlot)) +
        tm_borders(col = "gray") +
        tm_fill(col="ZCTA5CE20", alpha=0.5,legend.show=FALSE) +
        tm_text("ZCTA5CE20", size=0.5) +
        
        ## pre-redistricting LD is in blue, no shading
        tm_shape( thisDistrictMapOld ) +  
        tm_borders(col = "cornflowerblue", lty=2, lwd=2)  +

        ## 2022 redistricted LD is in red, with shading
        tm_shape( thisDistrictMap ) +  
        tm_fill(col="pink", alpha=0.25) +
        tm_borders(col = "red", lty=2, lwd=2)  +
        
        tm_layout(main.title=myTitle, 
                  main.title.size = 0.9)
    if(!is.null(savePlot)) {
        # we don't overwrite
        if(!file.exists(savePlot)) {
            tmap_options(show.messages=FALSE)
            tmap_save(p, filename=savePlot)
            tmap_options_reset()
        }
    }
    return(p)
}

### load the pre-redistricting maps.  I won't do this at the top of the script, jsut to make absolutely sure that all the above analysis uses the new districts
load(here("saved_R_objects/WA_stateLegDists_proj.rda"))
load(here("saved_R_objects/WA_congDists_proj.rda"))

tmap_options(max.categories = as.integer(numZipsPerLD["max_zips_per_LD",1]))
# 
# ## plot for a single LD to test the function
# p <- plotDistrictAndZipCodes_redist(allZipMaps=WA_state_zipCodes_proj,
#         allDistrictMaps=LDs_redist_proj,
#         oldDistrictMaps=WA_stateLegDists_proj,
#         zip_LDredist_shrink1km_intersects_proj_plain,
#         district_short_name="LD_36",
#         savePlot = here("./test.pdf")
# )
# p


#### plots for all LDs
plotOutDir <- "output_to_share/version3_2022_Nov_redistricting2022_prettier/LDredist_zip_codes_uncurated_v3_2022_Nov2_plots"
allPlots <- list()
for(thisLD in unique(zip_LDredist_shrink1km_intersects_proj_plain$districtName)) {
    #cat("making plot for LD",thisLD,"\n")
    pdfFile <- paste(plotOutDir, "/", thisLD, "_redist_uncurated_v3_2022_Nov2_plot.pdf",sep="" )
    pdfFile <- here(pdfFile)
    
    allPlots[[thisLD]] <- plotDistrictAndZipCodes_redist(allZipMaps=WA_state_zipCodes_proj,
                        allDistrictMaps=LDs_redist_proj,
                        oldDistrictMaps=WA_stateLegDists_proj,
                        zipToDistrictTbl=zip_LDredist_shrink1km_intersects_proj_plain,
                        district_short_name=thisLD,
                        savePlot=pdfFile
                        )
}
```

    ## tmap options successfully reset
    ## tmap options successfully reset
    ## tmap options successfully reset
    ## tmap options successfully reset
    ## tmap options successfully reset
    ## tmap options successfully reset
    ## tmap options successfully reset
    ## tmap options successfully reset
    ## tmap options successfully reset
    ## tmap options successfully reset

    ## Warning: Number of levels of the variable "ZCTA5CE20" is 38, which is
    ## larger than max.categories (which is 30), so levels are combined. Set
    ## tmap_options(max.categories = 38) in the layer function to show all levels.

    ## Warning: Number of levels of the variable "ZCTA5CE20" is 38, which is
    ## larger than max.categories (which is 30), so levels are combined. Set
    ## tmap_options(max.categories = 38) in the layer function to show all levels.

    ## tmap options successfully reset
    ## tmap options successfully reset

    ## Warning: Number of levels of the variable "ZCTA5CE20" is 38, which is
    ## larger than max.categories (which is 30), so levels are combined. Set
    ## tmap_options(max.categories = 38) in the layer function to show all levels.

    ## Warning: Number of levels of the variable "ZCTA5CE20" is 38, which is
    ## larger than max.categories (which is 30), so levels are combined. Set
    ## tmap_options(max.categories = 38) in the layer function to show all levels.

    ## tmap options successfully reset
    ## tmap options successfully reset
    ## tmap options successfully reset
    ## tmap options successfully reset
    ## tmap options successfully reset
    ## tmap options successfully reset
    ## tmap options successfully reset
    ## tmap options successfully reset
    ## tmap options successfully reset
    ## tmap options successfully reset
    ## tmap options successfully reset
    ## tmap options successfully reset
    ## tmap options successfully reset
    ## tmap options successfully reset
    ## tmap options successfully reset
    ## tmap options successfully reset
    ## tmap options successfully reset
    ## tmap options successfully reset
    ## tmap options successfully reset
    ## tmap options successfully reset
    ## tmap options successfully reset
    ## tmap options successfully reset
    ## tmap options successfully reset
    ## tmap options successfully reset
    ## tmap options successfully reset
    ## tmap options successfully reset
    ## tmap options successfully reset
    ## tmap options successfully reset
    ## tmap options successfully reset
    ## tmap options successfully reset
    ## tmap options successfully reset
    ## tmap options successfully reset
    ## tmap options successfully reset
    ## tmap options successfully reset

    ## Warning: Number of levels of the variable "ZCTA5CE20" is 76, which is
    ## larger than max.categories (which is 30), so levels are combined. Set
    ## tmap_options(max.categories = 76) in the layer function to show all levels.

    ## Warning: Number of levels of the variable "ZCTA5CE20" is 76, which is
    ## larger than max.categories (which is 30), so levels are combined. Set
    ## tmap_options(max.categories = 76) in the layer function to show all levels.

    ## tmap options successfully reset
    ## tmap options successfully reset

    ## Warning: Number of levels of the variable "ZCTA5CE20" is 70, which is
    ## larger than max.categories (which is 30), so levels are combined. Set
    ## tmap_options(max.categories = 70) in the layer function to show all levels.

    ## Warning: Number of levels of the variable "ZCTA5CE20" is 70, which is
    ## larger than max.categories (which is 30), so levels are combined. Set
    ## tmap_options(max.categories = 70) in the layer function to show all levels.

    ## tmap options successfully reset

``` r
## show one plot
allPlots[["LD_36"]]
```

![](/Users/jayoung/Documents/WholeWashington/Whole_WA_data_wrangling_playground/reports/zip_to_LD_use_2022_redistricted_boundaries_v2_files/figure-gfm/unnamed-chunk-1-1.png)<!-- -->

``` r
# not really needed - it's very quick to read in the shp files
save(LDs_redist,file=here("saved_R_objects/LDs_redist.rda"))
save(CDs_redist,file=here("saved_R_objects/CDs_redist.rda"))
save(LDs_redist_proj,file=here("saved_R_objects/LDs_redist_proj.rda"))
save(CDs_redist_proj,file=here("saved_R_objects/CDs_redist_proj.rda"))

save(LDs_redist_proj_shrink1km,file=here("saved_R_objects/LDs_redist_proj_shrink1km.rda"))
save(CDs_redist_proj_shrink1km,file=here("saved_R_objects/CDs_redist_proj_shrink1km.rda"))

save(zip_CDredist_shrink1km_intersects_proj,file=here("saved_R_objects/zip_CDredist_shrink1km_intersects_proj.rda"))
save(zip_CDredist_shrink1km_intersects_proj_plain,file=here("saved_R_objects/zip_CDredist_shrink1km_intersects_proj_plain.rda"))

save(zip_LDredist_shrink1km_intersects_proj,file=here("saved_R_objects/zip_LDredist_shrink1km_intersects_proj.rda"))
save(zip_LDredist_shrink1km_intersects_proj_plain,file=here("saved_R_objects/zip_LDredist_shrink1km_intersects_proj_plain.rda"))
```

Show R version and package versions, in case of troubleshooting

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
    ##  [1] here_1.0.1       kableExtra_1.3.4 tmap_3.3-3       forcats_0.5.2   
    ##  [5] stringr_1.4.1    dplyr_1.0.10     purrr_0.3.5      readr_2.1.3     
    ##  [9] tidyr_1.2.1      tibble_3.1.8     ggplot2_3.3.6    tidyverse_1.3.2 
    ## [13] sf_1.0-8         tigris_1.6.1    
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] fs_1.5.2            lubridate_1.8.0     webshot_0.5.4      
    ##  [4] RColorBrewer_1.1-3  httr_1.4.4          rprojroot_2.0.3    
    ##  [7] tools_4.2.1         backports_1.4.1     utf8_1.2.2         
    ## [10] rgdal_1.5-32        R6_2.5.1            KernSmooth_2.23-20 
    ## [13] DBI_1.1.3           colorspace_2.0-3    raster_3.6-3       
    ## [16] withr_2.5.0         sp_1.5-0            tidyselect_1.2.0   
    ## [19] leaflet_2.1.1       compiler_4.2.1      leafem_0.2.0       
    ## [22] cli_3.4.1           rvest_1.0.3         xml2_1.3.3         
    ## [25] scales_1.2.1        classInt_0.4-8      proxy_0.4-27       
    ## [28] rappdirs_0.3.3      systemfonts_1.0.4   digest_0.6.30      
    ## [31] foreign_0.8-83      svglite_2.1.0       rmarkdown_2.17     
    ## [34] base64enc_0.1-3     dichromat_2.0-0.1   pkgconfig_2.0.3    
    ## [37] htmltools_0.5.3     highr_0.9           dbplyr_2.2.1       
    ## [40] fastmap_1.1.0       htmlwidgets_1.5.4   rlang_1.0.6        
    ## [43] readxl_1.4.1        rstudioapi_0.14     generics_0.1.3     
    ## [46] jsonlite_1.8.3      crosstalk_1.2.0     googlesheets4_1.0.1
    ## [49] magrittr_2.0.3      Rcpp_1.0.9          munsell_0.5.0      
    ## [52] fansi_1.0.3         abind_1.4-5         terra_1.6-17       
    ## [55] lifecycle_1.0.3     stringi_1.7.8       leafsync_0.1.0     
    ## [58] yaml_2.3.6          tmaptools_3.1-1     grid_4.2.1         
    ## [61] maptools_1.1-5      parallel_4.2.1      crayon_1.5.2       
    ## [64] lattice_0.20-45     haven_2.5.1         stars_0.5-6        
    ## [67] hms_1.1.2           knitr_1.40          pillar_1.8.1       
    ## [70] uuid_1.1-0          codetools_0.2-18    reprex_2.0.2       
    ## [73] XML_3.99-0.11       glue_1.6.2          evaluate_0.17      
    ## [76] modelr_0.1.9        png_0.1-7           vctrs_0.5.0        
    ## [79] tzdb_0.3.0          cellranger_1.1.0    gtable_0.3.1       
    ## [82] assertthat_0.2.1    xfun_0.34           lwgeom_0.2-9       
    ## [85] broom_1.0.1         e1071_1.7-11        class_7.3-20       
    ## [88] googledrive_2.0.0   viridisLite_0.4.1   gargle_1.2.1       
    ## [91] units_0.8-0         ellipsis_0.3.2
