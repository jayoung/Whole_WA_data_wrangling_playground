prep geographic overlaps
================
Janet Young
2022-10-31

Goal: figure out the overlaps between various types of geographic
regions. Save a table, and make a plot for each LD.

We use the region data we saved earlier, using the
[prep_geographic_areas.Rmd](Rscripts/prep_geographic_areas.Rmd) code.

Figure out the overlaps between zip codes and LDs. We keep the `sf`
style object with the geographic information, but we also make a plain
tibble.

``` r
zip_LDshrink1km_intersects_proj <- st_join(WA_state_zipCodes_proj, 
                                           WA_stateLegDists_proj_shrink1km, 
                                           join = st_intersects, 
                                           left=FALSE)
zip_LDshrink1km_intersects_proj_plain <- zip_LDshrink1km_intersects_proj %>%
    select(ZCTA5CE20,NAMELSAD) %>%
    as_tibble() %>%
    select(-geometry) %>% 
    arrange(NAMELSAD) %>% 
    rename(leg_dist=NAMELSAD) %>% 
    rename(zip_code=ZCTA5CE20) %>% 
    mutate(leg_dist_short=gsub("State Senate District ","LD_",leg_dist))
```

Do the same for congressional districts - get the overlaps between zip
codes and CDs.

``` r
zip_CDshrink1km_intersects_proj <- st_join(WA_state_zipCodes_proj, 
                                           WA_congDists_proj_shrink1km, 
                                           join = st_intersects, 
                                           left=FALSE)

zip_CDshrink1km_intersects_proj_plain <- zip_CDshrink1km_intersects_proj %>%
    select(ZCTA5CE20,NAMELSAD) %>%
    as_tibble() %>%
    select(-geometry) %>% 
    arrange(NAMELSAD) %>% 
    rename(cong_dist=NAMELSAD) %>% 
    rename(zip_code=ZCTA5CE20) %>% 
    mutate(cong_dist_short=gsub("Congressional District ","CD_",cong_dist))
```

Now see which zip codes are in WA state, using the 1km ‘shrunken’
boundaries.

``` r
zip_WAstate_shrink1km_intersects_proj <- st_join(WA_state_zipCodes_proj, 
                                           WA_state_proj_shrink1km, 
                                           join = st_intersects, 
                                           left=FALSE)

zip_WAstate_shrink1km_intersects_proj_plain <- zip_WAstate_shrink1km_intersects_proj %>%
    select(ZCTA5CE20) %>%
    as_tibble() %>%
    select(-geometry) %>% 
    arrange(ZCTA5CE20) %>% 
    rename(zip_code=ZCTA5CE20)
```

The table is sorted by zip code. I’ll show the top and bottom entries
below.

``` r
zip_WAstate_shrink1km_intersects_proj_plain %>% head(3) %>% kable() %>% kable_styling()
```

<table class="table" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
zip_code
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
83856
</td>
</tr>
<tr>
<td style="text-align:left;">
98001
</td>
</tr>
<tr>
<td style="text-align:left;">
98002
</td>
</tr>
</tbody>
</table>

``` r
zip_WAstate_shrink1km_intersects_proj_plain %>% tail(3) %>% kable() %>% kable_styling()
```

<table class="table" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
zip_code
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
99401
</td>
</tr>
<tr>
<td style="text-align:left;">
99402
</td>
</tr>
<tr>
<td style="text-align:left;">
99403
</td>
</tr>
</tbody>
</table>

Looks good (mostly) - zip codes starting [980-994 are all in
WA](https://simple.wikipedia.org/wiki/List_of_ZIP_Code_prefixes) (995
and above is Alaska)

Turns out 83856 is a weird zip code - it’s mostly in Idaho but it DOES
have a bit sticking out \~5 miles into WA state (north of Spokane).

Now we have table of all WA state zip codes, we’ll be able to see
whether there were any zip codes that did not get assigned to a
district.

How many LDs is each zip code in? boundaries don’t line up, so some are
in \>1.

``` r
zip_LDshrink1km_intersects_proj_plain %>% 
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
412
</td>
</tr>
<tr>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
155
</td>
</tr>
<tr>
<td style="text-align:right;">
3
</td>
<td style="text-align:right;">
30
</td>
</tr>
</tbody>
</table>

What are the zips that were not assigned to LDs? They might be so small
they got missed because of the 1km shrinkage of the LD boundaries

``` r
zips_without_LDs <- setdiff(zip_WAstate_shrink1km_intersects_proj_plain$zip_code,  
                            zip_LDshrink1km_intersects_proj_plain$zip_code)
zips_without_LDs
```

    ## [1] "98101" "98154" "98164" "98174" "98195" "98330" "98559" "98583" "99251"

``` r
## I checked - there are no zips from outside WA state assigned to LDs 
# setdiff( zip_LDshrink1km_intersects_proj_plain$zip_code, zip_WAstate_shrink1km_intersects_proj_plain$zip_code)
```

How many CDs is each zip code in? boundaries don’t line up, so some are
in \>1.

``` r
zip_CDshrink1km_intersects_proj_plain %>% 
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
542
</td>
</tr>
<tr>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
59
</td>
</tr>
</tbody>
</table>

What are the zips that were not assigned to CDs?

``` r
zips_without_CDs <- setdiff(zip_WAstate_shrink1km_intersects_proj_plain$zip_code,  
                            zip_CDshrink1km_intersects_proj_plain$zip_code)
zips_without_CDs
```

    ## [1] "98154" "98164" "98174" "98330" "98558"

``` r
## I checked - there are no zips from outside WA state assigned to CDs 
## setdiff( zip_CDshrink1km_intersects_proj_plain$zip_code, zip_WAstate_shrink1km_intersects_proj_plain$zip_code)
```

Save all the R objects to use in other sessions

``` r
save(zip_LDshrink1km_intersects_proj, file=here("saved_R_objects/zip_LDshrink1km_intersects_proj.rda"))
save(zip_LDshrink1km_intersects_proj_plain, file=here("saved_R_objects/zip_LDshrink1km_intersects_proj_plain.rda"))

save(zip_CDshrink1km_intersects_proj, file=here("saved_R_objects/zip_CDshrink1km_intersects_proj.rda"))
save(zip_CDshrink1km_intersects_proj_plain, file=here("saved_R_objects/zip_CDshrink1km_intersects_proj_plain.rda"))

save(zip_WAstate_shrink1km_intersects_proj, file=here("saved_R_objects/zip_WAstate_shrink1km_intersects_proj.rda"))
save(zip_WAstate_shrink1km_intersects_proj_plain, file=here("saved_R_objects/zip_WAstate_shrink1km_intersects_proj_plain.rda"))

save(zips_without_CDs, zips_without_LDs, file=here("saved_R_objects/missingZips.rda"))
```

Look at the range of number of zip codes per LD / CD

``` r
numZipsPerLD <- zip_LDshrink1km_intersects_proj_plain %>% 
    count(leg_dist_short) %>% 
    rename(num_zips_per_LD=n) %>% 
    summarize(min_zips_per_LD=min(num_zips_per_LD),
              max_zips_per_LD=max(num_zips_per_LD)) %>% 
    t()

numZipsPerCD <- zip_CDshrink1km_intersects_proj_plain %>% 
    count(cong_dist_short) %>% 
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
6
</td>
</tr>
<tr>
<td style="text-align:left;">
max_zips_per_LD
</td>
<td style="text-align:right;">
56
</td>
</tr>
<tr>
<td style="text-align:left;">
min_zips_per_CD
</td>
<td style="text-align:right;">
30
</td>
</tr>
<tr>
<td style="text-align:left;">
max_zips_per_CD
</td>
<td style="text-align:right;">
120
</td>
</tr>
</tbody>
</table>

Now export the LD to zip tibble in a similar format to Kelsey’s google
sheet. Can’t just `pivot_wider()`, because some zips are present more
than once and the columns have different lengths. (or maybe we could if
we messed around a bit) I just used data.frame and a for loop instead.

``` r
makeWideTable <- function(zipToDist_tbl, maxZips=0, 
                          missingZips=NULL, saveToFile=NULL) {
    x <- data.frame(row.names=1:maxZips)
    if(!is.null(missingZips)) {
        x[,"no_district_assigned"] <- NA
        x[1:length(missingZips),"no_district_assigned"] <- missingZips
    }
    distNames <- zipToDist_tbl %>% 
        select(dist) %>% 
        mutate(numeric_dist=as.integer(gsub("LD_|CD_","",dist))) %>% 
        arrange(numeric_dist) %>% 
        select(-numeric_dist) %>% 
        unique() %>% 
        unlist(use.names = FALSE) 
    for (thisDist in distNames) {
        theseZips <- zipToDist_tbl %>% 
            filter(dist==thisDist) %>% 
            select(zip_code) %>% 
            arrange(zip_code) %>% 
            unlist(use.names = FALSE)
        
        x[,thisDist] <- NA
        x[1:length(theseZips),thisDist] <- theseZips
    }
    if(!is.null(saveToFile)) {
        write.table(x, file=saveToFile, na="", quote=FALSE, sep="\t", row.names = FALSE)
    }
    return(x)  
}

### get LD zip table
LDzip_wide <- zip_LDshrink1km_intersects_proj_plain %>% 
    rename(dist=leg_dist_short) %>% 
    makeWideTable(maxZips=numZipsPerLD["max_zips_per_LD",1], 
                  missingZips=zips_without_LDs,
                  saveToFile=here("output_to_share/LD_zip_codes_uncurated_v1_2022_Oct30.tsv"))

### get CD zip table
CDzip_wide <- zip_CDshrink1km_intersects_proj_plain %>% 
    rename(dist=cong_dist_short) %>% 
    makeWideTable(maxZips=numZipsPerCD["max_zips_per_CD",1], 
                  missingZips=zips_without_CDs,
                  saveToFile=here("output_to_share/CD_zip_codes_uncurated_v1_2022_Oct30.tsv"))
```

now make a plot for each LD, showing the zip codes we assigned to it.

(will be able to modify this function to work on CDs too - need to fix
some column names first)

``` r
plotDistrictAndZipCodes <- function(allZipMaps=WA_state_zipCodes_proj,
                                    zipToDistrictPlainTbl,
                                    district_short_name,
                                    savePlot=NULL) {
    
    zips_to_plot <- zipToDistrictPlainTbl %>% 
        filter(leg_dist_short==district_short_name) %>% 
        select(zip_code) %>% 
        unlist(use.names = FALSE)
    myTitle <- paste(district_short_name, "(red) and assigned zip codes (uncurated)")
    
    p <- tm_shape(allZipMaps %>% filter(ZCTA5CE20 %in% zips_to_plot)) +
        tm_borders(col = "gray") +
        tm_fill(col="ZCTA5CE20", alpha=0.5,legend.show=FALSE) +
        tm_text("ZCTA5CE20", size=0.5) +
        
        tm_shape( WA_stateLegDists_proj %>% filter(shortName==district_short_name) ) +  
        tm_fill(col="pink", alpha=0.25) +
        tm_borders(col = "red", lty=2, lwd=2)  +
        
        tm_layout(main.title=myTitle, 
                  main.title.size = 0.9)
    if(!is.null(savePlot)) {
        # we don't overwrite
        if(!file.exists(savePlot)) {
            tmap_save(p, filename=savePlot)
        }
    }
    return(p)
}

### plot for a single LD to test the function
# p <- plotDistrictAndZipCodes(allZipMaps=WA_state_zipCodes_proj,
#                         zip_LDshrink1km_intersects_proj_plain,
#                         district_short_name="LD_1",
#                         savePlot = here("output_to_share/LD_zip_codes_uncurated_v1_2022_Oct30_plots/LD_1_uncurated_v1_2022_Oct30_plot.pdf")
#                         )

#### plots for all LDs
plotOutDir <- "output_to_share/LD_zip_codes_uncurated_v1_2022_Oct30_plots"
allPlots <- list()
for(thisLD in unique(zip_LDshrink1km_intersects_proj_plain$leg_dist_short)) {
    #cat("making plot for LD",thisLD,"\n")
    pdfFile <- paste(plotOutDir, "/", thisLD, "_uncurated_v1_2022_Oct30_plot.pdf",sep="" )
    pdfFile <- here(pdfFile)
    
    allPlots[[thisLD]] <- plotDistrictAndZipCodes(allZipMaps=WA_state_zipCodes_proj,
                        zip_LDshrink1km_intersects_proj_plain,
                        district_short_name=thisLD,
                        savePlot=pdfFile
                        )
}

## show one plot
allPlots[["LD_1"]]
```

![](/Users/jayoung/Documents/WholeWashington/Whole_WA_data_wrangling_playground/reports/prep_geographic_overlaps_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

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
