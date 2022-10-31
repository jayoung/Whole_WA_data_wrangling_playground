Playing with some R packages to look at geography
================
Janet Young
2022-10-22

# Try `tidycensus` package

This package is designed to query census data. Population counts, and
registered voter counts could be useful for Whole WA questions, but more
usefully I think we can use it to look up boundaries for zip codes and
LDs. Maybe there are more direct ways to get the map data? (xxx to do:
research `tigris` package)

It’s tempting to look at other census data too (e.g. age, income) but we
should probably stay focussed (for now!).

Available geographic levels are listed
[here](https://walker-data.com/tidycensus/articles/basic-usage.html) and
include:  
+ “state”  
+ “county”  
+ “zip code tabulation area”  
+ “state legislative district (upper chamber)”  
+ “state legislative district (lower chamber)”  
+ “voting district”

## Tutorials, notes

Tidycensus functions are listed
[here](https://walker-data.com/tidycensus/reference/index.html)

Basic usage is described
[here](https://walker-data.com/tidycensus/articles/basic-usage.html)

Usage for spatial data is described
[here](https://walker-data.com/tidycensus/articles/spatial-data.html)

Tidycensus has two major functions:  
+ `get_decennial()`, which grants access to the 2000, 2010, and 2020
decennial US Census APIs  
+ `get_acs()`, which grants access to the 1-year and 5-year American
Community Survey APIs

If we include `geometry = TRUE` in a tidycensus function call,
tidycensus retrieves geographic data from the US Census Bureau (using
the `tigris` package). Spatial data gets merged with the tabular data we
requested, in the `geometry` column.

We can use `ggplot + geom_sf` to plot the data as maps

## What data is available to us?

Each census dataset has thousands of variables.

Here, I get the variable codes for a couple of datasets:

``` r
acs5_2017_vars <- load_variables(2017, "acs5", cache = TRUE)
sf1_2010_vars <- load_variables(2010, "sf1", cache = TRUE)
```

And show three random rows of each resulting table:

``` r
acs5_2017_vars %>% 
    slice_sample(n=3) %>% 
    kable(caption="Example variables from 2017 acs5 dataset") %>% 
    kable_styling(font_size = 9)
```

<table class="table" style="font-size: 9px; margin-left: auto; margin-right: auto;">
<caption style="font-size: initial !important;">
Example variables from 2017 acs5 dataset
</caption>
<thead>
<tr>
<th style="text-align:left;">
name
</th>
<th style="text-align:left;">
label
</th>
<th style="text-align:left;">
concept
</th>
<th style="text-align:left;">
geography
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
B08132_053
</td>
<td style="text-align:left;">
Estimate!!Total!!Public transportation (excluding taxicab)!!7 30 a.m. to
7 59 a.m.
</td>
<td style="text-align:left;">
MEANS OF TRANSPORTATION TO WORK BY TIME LEAVING HOME TO GO TO WORK
</td>
<td style="text-align:left;">
tract
</td>
</tr>
<tr>
<td style="text-align:left;">
B24123_355
</td>
<td style="text-align:left;">
Estimate!!Total!!Plasterers and stucco masons
</td>
<td style="text-align:left;">
DETAILED OCCUPATION BY MEDIAN EARNINGS IN THE PAST 12 MONTHS (IN 2017
INFLATION-ADJUSTED DOLLARS) FOR THE FULL-TIME, YEAR-ROUND CIVILIAN
EMPLOYED FEMALE POPULATION 16 YEARS AND OVER
</td>
<td style="text-align:left;">
us
</td>
</tr>
<tr>
<td style="text-align:left;">
B17007_023
</td>
<td style="text-align:left;">
Estimate!!Total!!Income in the past 12 months at or above poverty level
</td>
<td style="text-align:left;">
POVERTY STATUS IN THE PAST 12 MONTHS OF UNRELATED INDIVIDUALS 15 YEARS
AND OVER BY SEX BY AGE
</td>
<td style="text-align:left;">
tract
</td>
</tr>
</tbody>
</table>

``` r
sf1_2010_vars %>% 
    slice_sample(n=3) %>% 
    kable(caption="Example variables from 2010 sf1 dataset") %>% 
    kable_styling(font_size = 9)
```

<table class="table" style="font-size: 9px; margin-left: auto; margin-right: auto;">
<caption style="font-size: initial !important;">
Example variables from 2010 sf1 dataset
</caption>
<thead>
<tr>
<th style="text-align:left;">
name
</th>
<th style="text-align:left;">
label
</th>
<th style="text-align:left;">
concept
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
PCT022G011
</td>
<td style="text-align:left;">
Total!!Male!!Noninstitutionalized population (501, 601-602, 701-702,
704, 706, 801-802, 900-901, 903-904)!!Other noninstitutional facilities
(701-702, 704, 706, 801-802, 900-901, 903-904)
</td>
<td style="text-align:left;">
GROUP QUARTERS POPULATION BY SEX BY GROUP QUARTERS TYPE FOR THE
POPULATION 18 YEARS AND OVER (TWO OR MORE RACES)
</td>
</tr>
<tr>
<td style="text-align:left;">
PCT001016
</td>
<td style="text-align:left;">
Total tribes tallied (300, A01-M38, M41-R98, S01-Z99)!!American Indian
tribes, specified (A01-M38, T01-Z99)!!Creek (C64-C80)
</td>
<td style="text-align:left;">
AMERICAN INDIAN AND ALASKA NATIVE ALONE WITH ONE TRIBE REPORTED FOR
SELECTED TRIBES
</td>
</tr>
<tr>
<td style="text-align:left;">
PCT020007
</td>
<td style="text-align:left;">
Total!!Institutionalized population (101-106, 201-203, 301,
401-405)!!Correctional facilities for adults (101-106)!!Local jails and
other municipal confinement facilities (104)
</td>
<td style="text-align:left;">
GROUP QUARTERS POPULATION BY GROUP QUARTERS TYPE
</td>
</tr>
</tbody>
</table>

## Example: median age by WA state county

Get median age by WA state county

``` r
age_WAcounties_2010 <- get_decennial(geography = "county", 
                                     state = "WA", 
                                     variables = "P013001", 
                                     year = 2010,
                                     geometry = TRUE)
```

    ##   |                                                                              |                                                                      |   0%  |                                                                              |                                                                      |   1%  |                                                                              |=                                                                     |   1%  |                                                                              |=                                                                     |   2%  |                                                                              |==                                                                    |   2%  |                                                                              |==                                                                    |   3%  |                                                                              |==                                                                    |   4%  |                                                                              |===                                                                   |   4%  |                                                                              |===                                                                   |   5%  |                                                                              |====                                                                  |   5%  |                                                                              |====                                                                  |   6%  |                                                                              |=====                                                                 |   7%  |                                                                              |=====                                                                 |   8%  |                                                                              |======                                                                |   8%  |                                                                              |======                                                                |   9%  |                                                                              |=======                                                               |   9%  |                                                                              |=======                                                               |  10%  |                                                                              |=======                                                               |  11%  |                                                                              |========                                                              |  11%  |                                                                              |========                                                              |  12%  |                                                                              |=========                                                             |  12%  |                                                                              |=========                                                             |  13%  |                                                                              |=========                                                             |  14%  |                                                                              |==========                                                            |  14%  |                                                                              |==========                                                            |  15%  |                                                                              |===========                                                           |  15%  |                                                                              |===========                                                           |  16%  |                                                                              |============                                                          |  16%  |                                                                              |============                                                          |  17%  |                                                                              |=============                                                         |  18%  |                                                                              |=============                                                         |  19%  |                                                                              |==============                                                        |  19%  |                                                                              |==============                                                        |  20%  |                                                                              |==============                                                        |  21%  |                                                                              |===============                                                       |  21%  |                                                                              |===============                                                       |  22%  |                                                                              |================                                                      |  22%  |                                                                              |================                                                      |  23%  |                                                                              |=================                                                     |  25%  |                                                                              |==================                                                    |  25%  |                                                                              |==================                                                    |  26%  |                                                                              |===================                                                   |  26%  |                                                                              |===================                                                   |  27%  |                                                                              |===================                                                   |  28%  |                                                                              |====================                                                  |  28%  |                                                                              |====================                                                  |  29%  |                                                                              |=====================                                                 |  29%  |                                                                              |=====================                                                 |  30%  |                                                                              |=====================                                                 |  31%  |                                                                              |======================                                                |  31%  |                                                                              |======================                                                |  32%  |                                                                              |=======================                                               |  32%  |                                                                              |=======================                                               |  33%  |                                                                              |========================                                              |  34%  |                                                                              |========================                                              |  35%  |                                                                              |=========================                                             |  35%  |                                                                              |=========================                                             |  36%  |                                                                              |==========================                                            |  36%  |                                                                              |==========================                                            |  37%  |                                                                              |==========================                                            |  38%  |                                                                              |===========================                                           |  38%  |                                                                              |===========================                                           |  39%  |                                                                              |============================                                          |  39%  |                                                                              |============================                                          |  40%  |                                                                              |============================                                          |  41%  |                                                                              |=============================                                         |  41%  |                                                                              |=============================                                         |  42%  |                                                                              |==============================                                        |  42%  |                                                                              |==============================                                        |  43%  |                                                                              |===============================                                       |  44%  |                                                                              |===============================                                       |  45%  |                                                                              |================================                                      |  45%  |                                                                              |================================                                      |  46%  |                                                                              |=================================                                     |  46%  |                                                                              |=================================                                     |  47%  |                                                                              |=================================                                     |  48%  |                                                                              |==================================                                    |  48%  |                                                                              |==================================                                    |  49%  |                                                                              |===================================                                   |  50%  |                                                                              |====================================                                  |  51%  |                                                                              |====================================                                  |  52%  |                                                                              |=====================================                                 |  52%  |                                                                              |=====================================                                 |  53%  |                                                                              |======================================                                |  54%  |                                                                              |======================================                                |  55%  |                                                                              |=======================================                               |  55%  |                                                                              |=======================================                               |  56%  |                                                                              |========================================                              |  56%  |                                                                              |========================================                              |  57%  |                                                                              |========================================                              |  58%  |                                                                              |=========================================                             |  58%  |                                                                              |=========================================                             |  59%  |                                                                              |==========================================                            |  59%  |                                                                              |==========================================                            |  60%  |                                                                              |==========================================                            |  61%  |                                                                              |===========================================                           |  61%  |                                                                              |===========================================                           |  62%  |                                                                              |============================================                          |  62%  |                                                                              |============================================                          |  63%  |                                                                              |============================================                          |  64%  |                                                                              |=============================================                         |  64%  |                                                                              |=============================================                         |  65%  |                                                                              |==============================================                        |  65%  |                                                                              |==============================================                        |  66%  |                                                                              |===============================================                       |  67%  |                                                                              |===============================================                       |  68%  |                                                                              |================================================                      |  68%  |                                                                              |================================================                      |  69%  |                                                                              |=================================================                     |  69%  |                                                                              |=================================================                     |  70%  |                                                                              |=================================================                     |  71%  |                                                                              |==================================================                    |  71%  |                                                                              |==================================================                    |  72%  |                                                                              |===================================================                   |  72%  |                                                                              |===================================================                   |  73%  |                                                                              |===================================================                   |  74%  |                                                                              |====================================================                  |  74%  |                                                                              |====================================================                  |  75%  |                                                                              |=====================================================                 |  75%  |                                                                              |=====================================================                 |  76%  |                                                                              |======================================================                |  77%  |                                                                              |======================================================                |  78%  |                                                                              |=======================================================               |  78%  |                                                                              |=======================================================               |  79%  |                                                                              |========================================================              |  79%  |                                                                              |========================================================              |  80%  |                                                                              |========================================================              |  81%  |                                                                              |=========================================================             |  81%  |                                                                              |=========================================================             |  82%  |                                                                              |==========================================================            |  82%  |                                                                              |==========================================================            |  83%  |                                                                              |===========================================================           |  84%  |                                                                              |===========================================================           |  85%  |                                                                              |============================================================          |  85%  |                                                                              |============================================================          |  86%  |                                                                              |=============================================================         |  86%  |                                                                              |=============================================================         |  87%  |                                                                              |=============================================================         |  88%  |                                                                              |==============================================================        |  88%  |                                                                              |==============================================================        |  89%  |                                                                              |===============================================================       |  89%  |                                                                              |===============================================================       |  90%  |                                                                              |===============================================================       |  91%  |                                                                              |================================================================      |  91%  |                                                                              |================================================================      |  92%  |                                                                              |=================================================================     |  92%  |                                                                              |=================================================================     |  93%  |                                                                              |=================================================================     |  94%  |                                                                              |==================================================================    |  94%  |                                                                              |==================================================================    |  95%  |                                                                              |===================================================================   |  95%  |                                                                              |===================================================================   |  96%  |                                                                              |====================================================================  |  97%  |                                                                              |====================================================================  |  98%  |                                                                              |===================================================================== |  98%  |                                                                              |===================================================================== |  99%  |                                                                              |======================================================================|  99%  |                                                                              |======================================================================| 100%

``` r
age_WAcounties_2010 <- age_WAcounties_2010 %>% 
    mutate(NAME=gsub(" County, Washington","",NAME))
```

and make a graph

``` r
age_WAcounties_2010 %>%
    ggplot(aes(x = value, y = reorder(NAME, value))) + 
    geom_point() +
    labs(x="Median age", y="", title = "Median age by WA state county (2010 census)")
```

![](test_geography_code_files/figure-gfm/plot%20it-1.png)<!-- -->

now plot on a map

``` r
ggplot(age_WAcounties_2010, aes(fill = value, color = value)) +
    geom_sf() +
    coord_sf(crs = 26914) +
    scale_fill_viridis(option = "magma", direction=-1) +
    scale_color_viridis(option = "magma", direction=-1) +
    labs(title="Median age by county, WA state (2010 census)", fill="age", color="age")
```

![](test_geography_code_files/figure-gfm/spatial%20plot%20of%20age%20by%20WA%20county-1.png)<!-- -->

We can also get age by zip code.

``` r
age_WA_zipCodes_2010 <- get_decennial(
    geography = "zip code tabulation area", 
    state = "WA", 
    #county="King County", ## doesn't seem to work. tried it a few ways
    variables = "P013001", 
    year = 2010,
    geometry = TRUE)
```

    ##   |                                                                              |                                                                      |   0%  |                                                                              |=                                                                     |   1%  |                                                                              |=                                                                     |   2%  |                                                                              |==                                                                    |   3%  |                                                                              |===                                                                   |   4%  |                                                                              |===                                                                   |   5%  |                                                                              |====                                                                  |   5%  |                                                                              |====                                                                  |   6%  |                                                                              |=====                                                                 |   6%  |                                                                              |=====                                                                 |   7%  |                                                                              |=====                                                                 |   8%  |                                                                              |======                                                                |   8%  |                                                                              |======                                                                |   9%  |                                                                              |=======                                                               |   9%  |                                                                              |=======                                                               |  10%  |                                                                              |=======                                                               |  11%  |                                                                              |========                                                              |  11%  |                                                                              |========                                                              |  12%  |                                                                              |=========                                                             |  12%  |                                                                              |=========                                                             |  13%  |                                                                              |==========                                                            |  14%  |                                                                              |==========                                                            |  15%  |                                                                              |===========                                                           |  15%  |                                                                              |===========                                                           |  16%  |                                                                              |============                                                          |  17%  |                                                                              |============                                                          |  18%  |                                                                              |=============                                                         |  18%  |                                                                              |=============                                                         |  19%  |                                                                              |==============                                                        |  20%  |                                                                              |===============                                                       |  21%  |                                                                              |===============                                                       |  22%  |                                                                              |================                                                      |  22%  |                                                                              |================                                                      |  23%  |                                                                              |================                                                      |  24%  |                                                                              |=================                                                     |  24%  |                                                                              |=================                                                     |  25%  |                                                                              |==================                                                    |  25%  |                                                                              |==================                                                    |  26%  |                                                                              |===================                                                   |  27%  |                                                                              |===================                                                   |  28%  |                                                                              |====================                                                  |  28%  |                                                                              |====================                                                  |  29%  |                                                                              |=====================                                                 |  29%  |                                                                              |=====================                                                 |  30%  |                                                                              |======================                                                |  31%  |                                                                              |======================                                                |  32%  |                                                                              |=======================                                               |  32%  |                                                                              |=======================                                               |  33%  |                                                                              |========================                                              |  34%  |                                                                              |========================                                              |  35%  |                                                                              |=========================                                             |  35%  |                                                                              |=========================                                             |  36%  |                                                                              |==========================                                            |  37%  |                                                                              |==========================                                            |  38%  |                                                                              |===========================                                           |  38%  |                                                                              |===========================                                           |  39%  |                                                                              |============================                                          |  39%  |                                                                              |============================                                          |  40%  |                                                                              |=============================                                         |  41%  |                                                                              |=============================                                         |  42%  |                                                                              |==============================                                        |  42%  |                                                                              |==============================                                        |  43%  |                                                                              |==============================                                        |  44%  |                                                                              |===============================                                       |  44%  |                                                                              |===============================                                       |  45%  |                                                                              |================================                                      |  45%  |                                                                              |================================                                      |  46%  |                                                                              |=================================                                     |  47%  |                                                                              |=================================                                     |  48%  |                                                                              |==================================                                    |  48%  |                                                                              |==================================                                    |  49%  |                                                                              |===================================                                   |  49%  |                                                                              |===================================                                   |  50%  |                                                                              |===================================                                   |  51%  |                                                                              |====================================                                  |  51%  |                                                                              |====================================                                  |  52%  |                                                                              |=====================================                                 |  52%  |                                                                              |=====================================                                 |  53%  |                                                                              |======================================                                |  54%  |                                                                              |======================================                                |  55%  |                                                                              |=======================================                               |  55%  |                                                                              |=======================================                               |  56%  |                                                                              |========================================                              |  56%  |                                                                              |========================================                              |  57%  |                                                                              |========================================                              |  58%  |                                                                              |=========================================                             |  58%  |                                                                              |=========================================                             |  59%  |                                                                              |==========================================                            |  60%  |                                                                              |==========================================                            |  61%  |                                                                              |===========================================                           |  61%  |                                                                              |===========================================                           |  62%  |                                                                              |============================================                          |  62%  |                                                                              |============================================                          |  63%  |                                                                              |=============================================                         |  64%  |                                                                              |=============================================                         |  65%  |                                                                              |==============================================                        |  65%  |                                                                              |==============================================                        |  66%  |                                                                              |===============================================                       |  67%  |                                                                              |===============================================                       |  68%  |                                                                              |================================================                      |  68%  |                                                                              |================================================                      |  69%  |                                                                              |=================================================                     |  70%  |                                                                              |==================================================                    |  71%  |                                                                              |==================================================                    |  72%  |                                                                              |===================================================                   |  72%  |                                                                              |===================================================                   |  73%  |                                                                              |====================================================                  |  74%  |                                                                              |====================================================                  |  75%  |                                                                              |=====================================================                 |  75%  |                                                                              |=====================================================                 |  76%  |                                                                              |======================================================                |  77%  |                                                                              |======================================================                |  78%  |                                                                              |=======================================================               |  78%  |                                                                              |=======================================================               |  79%  |                                                                              |========================================================              |  79%  |                                                                              |========================================================              |  80%  |                                                                              |========================================================              |  81%  |                                                                              |=========================================================             |  81%  |                                                                              |=========================================================             |  82%  |                                                                              |==========================================================            |  82%  |                                                                              |==========================================================            |  83%  |                                                                              |===========================================================           |  84%  |                                                                              |===========================================================           |  85%  |                                                                              |============================================================          |  85%  |                                                                              |============================================================          |  86%  |                                                                              |=============================================================         |  87%  |                                                                              |=============================================================         |  88%  |                                                                              |==============================================================        |  88%  |                                                                              |==============================================================        |  89%  |                                                                              |===============================================================       |  89%  |                                                                              |===============================================================       |  90%  |                                                                              |===============================================================       |  91%  |                                                                              |================================================================      |  91%  |                                                                              |================================================================      |  92%  |                                                                              |=================================================================     |  92%  |                                                                              |=================================================================     |  93%  |                                                                              |==================================================================    |  94%  |                                                                              |==================================================================    |  95%  |                                                                              |===================================================================   |  95%  |                                                                              |===================================================================   |  96%  |                                                                              |====================================================================  |  97%  |                                                                              |====================================================================  |  98%  |                                                                              |===================================================================== |  98%  |                                                                              |===================================================================== |  99%  |                                                                              |======================================================================|  99%  |                                                                              |======================================================================| 100%

``` r
age_WA_zipCodes_2010 <- age_WA_zipCodes_2010 %>%
    mutate(NAME=gsub(", Washington","",NAME)) %>%
    mutate(NAME=gsub("ZCTA5 ","",NAME))
```

Show median age on a map. The holes indicate that some zip codes are
missing from the dataset (or some areas don’t have zip codes? that’s
hard to imagine).

``` r
ggplot(age_WA_zipCodes_2010, aes(fill = value, color = value)) +
    geom_sf() +
    coord_sf(crs = 26914) +
    scale_fill_viridis(option = "magma", direction=-1) +
    scale_color_viridis(option = "magma", direction=-1) +
    labs(title="Median age by zip code, WA state (2010 census)", fill="age", color="age")
```

![](test_geography_code_files/figure-gfm/spatial%20plot%20of%20age%20by%20WA%20zip%20code-1.png)<!-- -->

xxx to do:  
+ learn about ways to zoom in on these plots, show them at a different
angle (explore `?coord_sf`)  
+ find variable code to get population data (and perhaps registered
voter data)

More notes on the spatial data, from
[here](https://walker-data.com/tidycensus/articles/spatial-data.html):
“data objects look much like the basic tidycensus output, but with a
geometry list-column describing the geometry of each feature, using the
geographic coordinate system NAD 1983 (EPSG: 4269) which is the default
for Census shapefiles. tidycensus uses the Census cartographic boundary
shapefiles for faster processing; if you prefer the TIGER/Line
shapefiles, set cb = FALSE in the function call.”

## Exporting spatial data

We can save data “shapefile” or “GeoJSON” files for use in external GIS
or visualization applications using `st_write` (sf package). Use in
ArcGIS, QGIS, Tableau, or any other application that reads shapefiles.

``` r
test_export_dir <- "test_sf_files"
if (!dir.exists(test_export_dir)) {dir.create(test_export_dir)}

age_WA_zipCodes_2010_output_file <- paste(test_export_dir, 
                                          "age_WA_zipCodes_2010.shp",
                                          sep="/")
if (!file.exists(age_WA_zipCodes_2010_output_file)) {
    st_write(age_WA_zipCodes_2010, age_WA_zipCodes_2010_output_file)
}
```

## Health data

There is some health-related data in the ACS data (e.g. how many people
purchased health insurance), but digging into that seems like a
distraction for now. (In the SF1 dataset, there are no variables where
‘concept’ column contains ‘health’)

``` r
acs5_2017_vars %>% 
    filter(grepl("health",concept,ignore.case = TRUE)) %>% 
    select(concept) %>% 
    unique() %>% 
    kable(caption="Health-related variables from 2017 acs5 dataset") %>% 
    kable_styling(font_size = 9)
```

<table class="table" style="font-size: 9px; margin-left: auto; margin-right: auto;">
<caption style="font-size: initial !important;">
Health-related variables from 2017 acs5 dataset
</caption>
<thead>
<tr>
<th style="text-align:left;">
concept
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
AGE BY DISABILITY STATUS BY HEALTH INSURANCE COVERAGE STATUS
</td>
</tr>
<tr>
<td style="text-align:left;">
HEALTH INSURANCE COVERAGE STATUS BY SEX BY AGE
</td>
</tr>
<tr>
<td style="text-align:left;">
PRIVATE HEALTH INSURANCE STATUS BY SEX BY AGE
</td>
</tr>
<tr>
<td style="text-align:left;">
PUBLIC HEALTH INSURANCE STATUS BY SEX BY AGE
</td>
</tr>
<tr>
<td style="text-align:left;">
TYPES OF HEALTH INSURANCE COVERAGE BY AGE
</td>
</tr>
<tr>
<td style="text-align:left;">
HEALTH INSURANCE COVERAGE STATUS AND TYPE BY EMPLOYMENT STATUS
</td>
</tr>
<tr>
<td style="text-align:left;">
HEALTH INSURANCE COVERAGE STATUS AND TYPE BY HOUSEHOLD INCOME IN THE
PAST 12 MONTHS (IN 2017 INFLATION-ADJUSTED DOLLARS)
</td>
</tr>
<tr>
<td style="text-align:left;">
HEALTH INSURANCE COVERAGE STATUS AND TYPE BY AGE BY EDUCATIONAL
ATTAINMENT
</td>
</tr>
<tr>
<td style="text-align:left;">
HEALTH INSURANCE COVERAGE STATUS AND TYPE BY CITIZENSHIP STATUS
</td>
</tr>
<tr>
<td style="text-align:left;">
HEALTH INSURANCE COVERAGE STATUS BY SEX BY ENROLLMENT STATUS FOR YOUNG
ADULTS AGED 19 TO 25
</td>
</tr>
<tr>
<td style="text-align:left;">
PRIVATE HEALTH INSURANCE BY SEX BY ENROLLMENT STATUS FOR YOUNG ADULTS
AGED 19 TO 25
</td>
</tr>
<tr>
<td style="text-align:left;">
ALLOCATION OF HEALTH INSURANCE COVERAGE
</td>
</tr>
<tr>
<td style="text-align:left;">
ALLOCATION OF PRIVATE HEALTH INSURANCE
</td>
</tr>
<tr>
<td style="text-align:left;">
ALLOCATION OF PUBLIC HEALTH INSURANCE
</td>
</tr>
<tr>
<td style="text-align:left;">
ALLOCATION OF EMPLOYER-BASED HEALTH INSURANCE
</td>
</tr>
<tr>
<td style="text-align:left;">
ALLOCATION OF DIRECT-PURCHASE HEALTH INSURANCE
</td>
</tr>
<tr>
<td style="text-align:left;">
ALLOCATION OF TRICARE/MILITARY HEALTH COVERAGE
</td>
</tr>
<tr>
<td style="text-align:left;">
ALLOCATION OF VA HEALTH CARE
</td>
</tr>
<tr>
<td style="text-align:left;">
HEALTH INSURANCE COVERAGE STATUS BY AGE (WHITE ALONE)
</td>
</tr>
<tr>
<td style="text-align:left;">
HEALTH INSURANCE COVERAGE STATUS BY AGE (BLACK OR AFRICAN AMERICAN
ALONE)
</td>
</tr>
<tr>
<td style="text-align:left;">
HEALTH INSURANCE COVERAGE STATUS BY AGE (AMERICAN INDIAN AND ALASKA
NATIVE ALONE)
</td>
</tr>
<tr>
<td style="text-align:left;">
HEALTH INSURANCE COVERAGE STATUS BY AGE (ASIAN ALONE)
</td>
</tr>
<tr>
<td style="text-align:left;">
HEALTH INSURANCE COVERAGE STATUS BY AGE (NATIVE HAWAIIAN AND OTHER
PACIFIC ISLANDER ALONE)
</td>
</tr>
<tr>
<td style="text-align:left;">
HEALTH INSURANCE COVERAGE STATUS BY AGE (SOME OTHER RACE ALONE)
</td>
</tr>
<tr>
<td style="text-align:left;">
HEALTH INSURANCE COVERAGE STATUS BY AGE (TWO OR MORE RACES)
</td>
</tr>
<tr>
<td style="text-align:left;">
HEALTH INSURANCE COVERAGE STATUS BY AGE (WHITE ALONE, NOT HISPANIC OR
LATINO)
</td>
</tr>
<tr>
<td style="text-align:left;">
HEALTH INSURANCE COVERAGE STATUS BY AGE (HISPANIC OR LATINO)
</td>
</tr>
<tr>
<td style="text-align:left;">
EMPLOYER-BASED HEALTH INSURANCE BY SEX BY AGE
</td>
</tr>
<tr>
<td style="text-align:left;">
DIRECT-PURCHASE HEALTH INSURANCE BY SEX BY AGE
</td>
</tr>
<tr>
<td style="text-align:left;">
TRICARE/MILITARY HEALTH COVERAGE BY SEX BY AGE
</td>
</tr>
<tr>
<td style="text-align:left;">
VA HEALTH CARE BY SEX BY AGE
</td>
</tr>
<tr>
<td style="text-align:left;">
HEALTH INSURANCE COVERAGE STATUS AND TYPE BY WORK EXPERIENCE
</td>
</tr>
<tr>
<td style="text-align:left;">
PRIVATE HEALTH INSURANCE BY WORK EXPERIENCE
</td>
</tr>
<tr>
<td style="text-align:left;">
PUBLIC HEALTH INSURANCE BY WORK EXPERIENCE
</td>
</tr>
<tr>
<td style="text-align:left;">
HEALTH INSURANCE COVERAGE STATUS BY RATIO OF INCOME TO POVERTY LEVEL IN
THE PAST 12 MONTHS BY AGE
</td>
</tr>
<tr>
<td style="text-align:left;">
PRIVATE HEALTH INSURANCE BY RATIO OF INCOME TO POVERTY LEVEL IN THE PAST
12 MONTHS BY AGE
</td>
</tr>
<tr>
<td style="text-align:left;">
PUBLIC HEALTH INSURANCE BY RATIO OF INCOME TO POVERTY LEVEL IN THE PAST
12 MONTHS BY AGE
</td>
</tr>
<tr>
<td style="text-align:left;">
HEALTH INSURANCE COVERAGE STATUS BY LIVING ARRANGEMENT
</td>
</tr>
</tbody>
</table>
