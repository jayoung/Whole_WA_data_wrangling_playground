# Whole_WA_data_wrangling_playground

Goal:  playground to test code to look at Whole WA data

The git repo lives [here](https://github.com/jayoung/Whole_WA_data_wrangling) 

Who's playing? Everyone is welcome.
- Janet Young. I started this repo. My expertise is mostly in R, so there's a bias towards R code. (I'm a beginner at using git for team projects - might need advice on handling pull requests, etc, use of different branches, etc)


## Geography/mapping tools

the tidycensus R package looks useful.  See [`test_geography_code.md`](test_geography_code.md)

### Other tools to explore

#### R packages

This [blog post](https://towardsdatascience.com/the-best-spatial-analysis-packages-to-use-in-r-35855069f8b2) discusses several packages, as does [this page](https://www.zevross.com/blog/2019/05/01/unscientific-list-of-popular-r-packages-for-spatial-analysis/) and [this page](https://www.gislounge.com/r-packages-for-spatial-analysis/)

- `tigris` R package - map data?
- [`GISTools`](https://rdrr.io/cran/GISTools/man/GISTools-package.html)
- [`maps`](https://cran.r-project.org/web/packages/maps/maps.pdf)

## Geography/mapping datasets

tidycensus R package also allows access to mapping data.  See [`test_geography_code.md`](test_geography_code.md)


The [Washington Geospatial Open Data Portal](https://geo.wa.gov/maps/648a84ebf320484e9d73717f76d1d042/about) might be useful. Tons of data on the portal, but the `LIHEAP Map`dataset (by user RezaKCommerceGIS) seems like it might have what we need. There are 5 layers:  
    + CensusTract_Summary
    + County_Summary
    + LegDistrict_Summary
    + CongDistrict_Summary
    + ZipCode_Summary


Or a dataset of [zip code boundaries](https://esri.maps.arcgis.com/home/item.html?id=a1569e93ecd2408d89f42e8770a90f76) from 2021 

