# Whole_WA_data_wrangling_playground

Goal:  playground to test code to look at Whole WA data

The git repo lives [here](https://github.com/jayoung/Whole_WA_data_wrangling) 

Who's playing? Everyone is welcome.
- Janet Young (@jayoung). I started this repo. My expertise is mostly in R, so there's a bias towards R code. (I'm a beginner at using git for team projects - might need advice on handling pull requests, etc, use of different branches, etc)  
- @Frijol (maybe?)

## repository organization

Scripts live in the `Rscripts` directory.

Some scripts are R markdown notebooks (`\*Rmd` files).  We can run Rmd scripts via the 'knit' function (e.g. the knit button in Rstudio).  I've set those notebooks so that their output appears in the `reports` directory (`\*md` files).



## version 1, zip code to LD mapping

All info comes from R's `tigris` package - uses 2020 census data.

step 1. Run `Rscripts/prep_geographic_areas.Rmd` - this gets maps of the geographic areas we care about, saves them as Rdata files.

step 2. Run `Rscripts/prep_geographic_overlaps.Rmd` - this figures out how zip codes overlap with LDs, writes a csv file that Kelsey can plug into her google sheet, and plots a map for each LD showing which zip codes we assigned to it.  Report includes some stats about how many LDs each zip code overlaps with. Output goes in output_to_share, file names contain `v1_2022_Oct30`.  Output also synced to git and uploaded to google drive.

## version 2, zip code to LD mapping

Now I use the LD boundaries after redistricting, downloaded from [WA state redistricting commission](https://www.redistricting.wa.gov/district-maps-handouts)

Still need to have run `Rscripts/prep_geographic_areas.Rmd` (for the version 1 analysis) to save zip codes (and old LD boundaries)

Run `Rscripts/zip_to_LD_use_2022_redistricted_boundaries.Rmd` - this creates the NEW table and maps using the 2022 redistricted boundaries



# other notes on how to code stuff

## Geography/mapping tools

the tidycensus R package looks useful.  See [`test_geography_code.md`](test_geography_code.md)

### Other tools to explore

#### R packages

This [blog post](https://towardsdatascience.com/the-best-spatial-analysis-packages-to-use-in-r-35855069f8b2) discusses several packages, as does [this page](https://www.zevross.com/blog/2019/05/01/unscientific-list-of-popular-r-packages-for-spatial-analysis/) and [this page](https://www.gislounge.com/r-packages-for-spatial-analysis/) and [this](https://crd230.github.io/lab3.html)

- `tigris` R package - map data?
- [`GISTools`](https://rdrr.io/cran/GISTools/man/GISTools-package.html)
- [`maps`](https://cran.r-project.org/web/packages/maps/maps.pdf)
- `mapview` for interactive mapping


"For help deciding on an appropriate coordinate reference system for your project, take a look at the [crsuggest package](https://github.com/walkerke/crsuggest."

More advice [here](https://walker-data.com/census-r/census-geographic-data-and-applications-in-r.html)

If shoreline boundaries look odd in plots, see [here](options(device = "X11")
X11.options(type = "cairo")
)

Understanding coordinate reference systems explained [here](WA_state_ZipCodes)

How do two geographic areas overlap each other - see [here](https://crd230.github.io/lab3.html)

Vocabulary: within, overlaps, intersects, contains, etc, explained [here](https://en.wikipedia.org/wiki/Spatial_relation)

Intersects versus overlaps - explained [here](https://resources.arcgis.com/en/help/arcobjects-net/componentHelp/index.html#//002500000086000000), maybe?  Intersects is true if the two objects have ANY spatial relationship.   For 'overlaps' to be true the intersection of the two objects must have the same dimensions as the original two shapes (i.e. for area/area to overlap, they have to have a non-zero area in the overlap, not just a line)

## Geography/mapping datasets

WA state provides shape files of the districts, via this [landing site](https://www.redistricting.wa.gov/district-maps-handouts)

```
cd downloads/WA_redistricting_commission_2022_Oct30
wget https://rdcext.blob.core.windows.net/public/1-District%20Maps/AMENDED%20FINAL%20DISTRICTS%202022_GIS-Ready.zip
# unpack
unzip AMENDED\ FINAL\ DISTRICTS\ 2022_GIS-Ready.zip
rm AMENDED\ FINAL\ DISTRICTS\ 2022_GIS-Ready.zip 
# clean up file names - get rid of spaces
mv 2022\ Final\ Adoped\ Districts_StatePlanePCS/ 2022_Final_Adoped_Districts_StatePlanePCS/
mv Final\ District\ Shapes\ 2022_NAD_83/ Final_District_Shapes_2022_NAD_83/
mv Final_District_Shapes_2022_NAD_83/Final\ District\ Shapes\ 2022/ Final_District_Shapes_2022_NAD_83/Final_District_Shapes_2022/
```
It's in NAD_83 coordinates. I have not used them yet - for now I am using the tigris data from 2020.

Also get the pdf files. They don't display well on my mac (missing font)
```
cd /Users/jayoung/Documents/WholeWashington/Whole_WA_data_wrangling_playground/downloads/WA_redistricting_commission_2022_Oct30/pdf_files

wget https://rdcext.blob.core.windows.net/public/2-Individual%20Districts/2022%20Legislative%20District%20Maps/Reduced%20LD%20PDFs/2022%20Adopted%20Legislative%20Map%20Full.pdf
wget https://rdcext.blob.core.windows.net/public/2-Individual%20Districts/2022%20Legislative%20District%20Maps/Reduced%20LD%20PDFs/2022%20Adopted%20Legislative%20Map%20Inset%201.pdf
wget https://rdcext.blob.core.windows.net/public/2-Individual%20Districts/2022%20Legislative%20District%20Maps/Reduced%20LD%20PDFs/2022%20Adopted%20Legislative%20Map%20Inset%202.pdf

wget https://rdcext.blob.core.windows.net/public/2-Individual%20Districts/2022%20Congessional%20District%20Maps/Reduced%20CD%20PDFs/2022%20Adopted%20Congressional%20Map%20Full.pdf
wget https://rdcext.blob.core.windows.net/public/2-Individual%20Districts/2022%20Congessional%20District%20Maps/Reduced%20CD%20PDFs/2022%20Adopted%20Congressional%20Map%20Inset%201.pdf
wget https://rdcext.blob.core.windows.net/public/2-Individual%20Districts/2022%20Congessional%20District%20Maps/Reduced%20CD%20PDFs/2022%20Adopted%20Congressional%20Map%20Inset%202.pdf
```
# other data sources

tidycensus R package also allows access to mapping data.  See [`test_geography_code.md`](test_geography_code.md)


The [Washington Geospatial Open Data Portal](https://geo.wa.gov/maps/648a84ebf320484e9d73717f76d1d042/about) might be useful. Tons of data on the portal, but the `LIHEAP Map`dataset (by user RezaKCommerceGIS) seems like it might have what we need. There are 5 layers:  
    + CensusTract_Summary
    + County_Summary
    + LegDistrict_Summary
    + CongDistrict_Summary
    + ZipCode_Summary


Or a dataset of [zip code boundaries](https://esri.maps.arcgis.com/home/item.html?id=a1569e93ecd2408d89f42e8770a90f76) from 2021 


if I have >1 tmap plot I can show them together using:  `tmap_arrange(left_plot, right_plot)`


