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
C02003_002
</td>
<td style="text-align:left;">
Estimate!!Total!!Population of one race
</td>
<td style="text-align:left;">
DETAILED RACE
</td>
<td style="text-align:left;">
block group
</td>
</tr>
<tr>
<td style="text-align:left;">
B08601_008
</td>
<td style="text-align:left;">
Estimate!!Total!!Car, truck, or van!!Carpooled!!In 5- or 6-person
carpool
</td>
<td style="text-align:left;">
MEANS OF TRANSPORTATION TO WORK FOR WORKPLACE GEOGRAPHY
</td>
<td style="text-align:left;">
county
</td>
</tr>
<tr>
<td style="text-align:left;">
B27022_015
</td>
<td style="text-align:left;">
Estimate!!Total!!Female!!Not enrolled in school!!No health insurance
coverage
</td>
<td style="text-align:left;">
HEALTH INSURANCE COVERAGE STATUS BY SEX BY ENROLLMENT STATUS FOR YOUNG
ADULTS AGED 19 TO 25
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
PCT012K136
</td>
<td style="text-align:left;">
Total!!Female!!29 years
</td>
<td style="text-align:left;">
SEX BY AGE (AMERICAN INDIAN AND ALASKA NATIVE ALONE, NOT HISPANIC OR
LATINO)
</td>
</tr>
<tr>
<td style="text-align:left;">
P024004
</td>
<td style="text-align:left;">
Total!!Households with one or more people 60 years and
over!!2-or-more-person household
</td>
<td style="text-align:left;">
HOUSEHOLDS BY PRESENCE OF PEOPLE 60 YEARS AND OVER, HOUSEHOLD SIZE, AND
HOUSEHOLD TYPE
</td>
</tr>
<tr>
<td style="text-align:left;">
PCT012K077
</td>
<td style="text-align:left;">
Total!!Male!!74 years
</td>
<td style="text-align:left;">
SEX BY AGE (AMERICAN INDIAN AND ALASKA NATIVE ALONE, NOT HISPANIC OR
LATINO)
</td>
</tr>
</tbody>
</table>

## Example 1: median age by state

Get the data:

``` r
## age10 is a tibble, 52 rows (each state), 4 columns
age10 <- get_decennial(geography = "state", 
                                variables = "P013001", 
                                year = 2010) 
```

Plot it:

``` r
age10 %>%
    ggplot(aes(x = value, y = reorder(NAME, value))) + 
    geom_point() +
    labs(x="Median age", y="", title = "Median age by state")
```

![](test_geography_code_files/figure-gfm/plot%20median%20age%20by%20state-1.png)<!-- -->

## Example 2 - spatial data

This example gets household income by tract in Tarrant county, Texas and
plots it spatially:

``` r
tarr <- get_acs(geography = "tract", variables = "B19013_001",
                state = "TX", county = "Tarrant", geometry = TRUE, year = 2020)
```

    ##   |                                                                              |                                                                      |   0%  |                                                                              |                                                                      |   1%  |                                                                              |=                                                                     |   1%  |                                                                              |=                                                                     |   2%  |                                                                              |==                                                                    |   2%  |                                                                              |==                                                                    |   3%  |                                                                              |===                                                                   |   4%  |                                                                              |===                                                                   |   5%  |                                                                              |====                                                                  |   5%  |                                                                              |====                                                                  |   6%  |                                                                              |=====                                                                 |   7%  |                                                                              |=====                                                                 |   8%  |                                                                              |======                                                                |   8%  |                                                                              |======                                                                |   9%  |                                                                              |=======                                                               |   9%  |                                                                              |=======                                                               |  10%  |                                                                              |=======                                                               |  11%  |                                                                              |========                                                              |  11%  |                                                                              |========                                                              |  12%  |                                                                              |=========                                                             |  12%  |                                                                              |=========                                                             |  13%  |                                                                              |==========                                                            |  14%  |                                                                              |==========                                                            |  15%  |                                                                              |===========                                                           |  16%  |                                                                              |============                                                          |  17%  |                                                                              |============                                                          |  18%  |                                                                              |=============                                                         |  18%  |                                                                              |=============                                                         |  19%  |                                                                              |==============                                                        |  20%  |                                                                              |==============                                                        |  21%  |                                                                              |===============                                                       |  21%  |                                                                              |===============                                                       |  22%  |                                                                              |================                                                      |  22%  |                                                                              |================                                                      |  23%  |                                                                              |=================                                                     |  24%  |                                                                              |=================                                                     |  25%  |                                                                              |==================                                                    |  25%  |                                                                              |==================                                                    |  26%  |                                                                              |===================                                                   |  26%  |                                                                              |===================                                                   |  27%  |                                                                              |===================                                                   |  28%  |                                                                              |====================                                                  |  28%  |                                                                              |====================                                                  |  29%  |                                                                              |=====================                                                 |  30%  |                                                                              |======================                                                |  31%  |                                                                              |======================                                                |  32%  |                                                                              |=======================                                               |  32%  |                                                                              |=======================                                               |  33%  |                                                                              |========================                                              |  34%  |                                                                              |========================                                              |  35%  |                                                                              |=========================                                             |  35%  |                                                                              |=========================                                             |  36%  |                                                                              |==========================                                            |  37%  |                                                                              |==========================                                            |  38%  |                                                                              |===========================                                           |  38%  |                                                                              |===========================                                           |  39%  |                                                                              |============================                                          |  39%  |                                                                              |============================                                          |  40%  |                                                                              |============================                                          |  41%  |                                                                              |=============================                                         |  41%  |                                                                              |=============================                                         |  42%  |                                                                              |==============================                                        |  42%  |                                                                              |==============================                                        |  43%  |                                                                              |===============================                                       |  44%  |                                                                              |===============================                                       |  45%  |                                                                              |================================                                      |  45%  |                                                                              |================================                                      |  46%  |                                                                              |=================================                                     |  47%  |                                                                              |=================================                                     |  48%  |                                                                              |==================================                                    |  48%  |                                                                              |==================================                                    |  49%  |                                                                              |===================================                                   |  49%  |                                                                              |===================================                                   |  50%  |                                                                              |===================================                                   |  51%  |                                                                              |====================================                                  |  51%  |                                                                              |====================================                                  |  52%  |                                                                              |=====================================                                 |  52%  |                                                                              |=====================================                                 |  53%  |                                                                              |======================================                                |  54%  |                                                                              |======================================                                |  55%  |                                                                              |=======================================                               |  55%  |                                                                              |=======================================                               |  56%  |                                                                              |========================================                              |  57%  |                                                                              |========================================                              |  58%  |                                                                              |=========================================                             |  58%  |                                                                              |=========================================                             |  59%  |                                                                              |==========================================                            |  59%  |                                                                              |==========================================                            |  60%  |                                                                              |===========================================                           |  61%  |                                                                              |===========================================                           |  62%  |                                                                              |============================================                          |  62%  |                                                                              |============================================                          |  63%  |                                                                              |=============================================                         |  64%  |                                                                              |=============================================                         |  65%  |                                                                              |==============================================                        |  65%  |                                                                              |==============================================                        |  66%  |                                                                              |===============================================                       |  67%  |                                                                              |===============================================                       |  68%  |                                                                              |================================================                      |  68%  |                                                                              |================================================                      |  69%  |                                                                              |=================================================                     |  69%  |                                                                              |=================================================                     |  70%  |                                                                              |==================================================                    |  71%  |                                                                              |==================================================                    |  72%  |                                                                              |===================================================                   |  72%  |                                                                              |===================================================                   |  73%  |                                                                              |===================================================                   |  74%  |                                                                              |====================================================                  |  74%  |                                                                              |====================================================                  |  75%  |                                                                              |=====================================================                 |  75%  |                                                                              |=====================================================                 |  76%  |                                                                              |======================================================                |  76%  |                                                                              |======================================================                |  77%  |                                                                              |======================================================                |  78%  |                                                                              |=======================================================               |  78%  |                                                                              |=======================================================               |  79%  |                                                                              |========================================================              |  79%  |                                                                              |========================================================              |  80%  |                                                                              |=========================================================             |  81%  |                                                                              |=========================================================             |  82%  |                                                                              |==========================================================            |  82%  |                                                                              |==========================================================            |  83%  |                                                                              |==========================================================            |  84%  |                                                                              |===========================================================           |  84%  |                                                                              |===========================================================           |  85%  |                                                                              |============================================================          |  85%  |                                                                              |============================================================          |  86%  |                                                                              |=============================================================         |  87%  |                                                                              |=============================================================         |  88%  |                                                                              |==============================================================        |  88%  |                                                                              |==============================================================        |  89%  |                                                                              |===============================================================       |  89%  |                                                                              |===============================================================       |  90%  |                                                                              |================================================================      |  91%  |                                                                              |================================================================      |  92%  |                                                                              |=================================================================     |  92%  |                                                                              |=================================================================     |  93%  |                                                                              |==================================================================    |  94%  |                                                                              |==================================================================    |  95%  |                                                                              |===================================================================   |  96%  |                                                                              |====================================================================  |  97%  |                                                                              |====================================================================  |  98%  |                                                                              |===================================================================== |  98%  |                                                                              |===================================================================== |  99%  |                                                                              |======================================================================| 100%

``` r
ggplot(tarr, aes(fill = estimate, color = estimate)) +
    geom_sf() +
    coord_sf(crs = 26914) +
    scale_fill_viridis(option = "magma") +
    scale_color_viridis(option = "magma") +
    labs(title="Household income by tract in Tarrant county, Texas")
```

![](test_geography_code_files/figure-gfm/tract%20mapping%20example%20-%20get%20data-1.png)<!-- -->

This gets data by county (household income in Vermont)

``` r
vt <- get_acs(geography = "county", variables = "B19013_001", state = "VT", year = 2019)

vt %>%
    mutate(NAME = gsub(" County, Vermont", "", NAME)) %>%
    ggplot(aes(x = estimate, y = reorder(NAME, estimate))) +
    geom_errorbar(aes(xmin = estimate - moe, xmax = estimate + moe), width = 0.3, size = 0.5) +
    geom_point(color = "red", size = 3) +
    labs(title = "Household income by county in Vermont",
         subtitle = "2015-2019 American Community Survey",
         y = "",
         x = "ACS estimate (bars represent margin of error)")
```

![](test_geography_code_files/figure-gfm/county%20mapping%20example%20-%20get%20data-1.png)<!-- -->

More on the spatial data, from
[here](https://walker-data.com/tidycensus/articles/spatial-data.html):
“Our object `tarr` looks much like the basic tidycensus output, but with
a geometry list-column describing the geometry of each feature, using
the geographic coordinate system NAD 1983 (EPSG: 4269) which is the
default for Census shapefiles. tidycensus uses the Census cartographic
boundary shapefiles for faster processing; if you prefer the TIGER/Line
shapefiles, set cb = FALSE in the function call.”

## Exporting spatial data

We can save data “shapefile” or “GeoJSON” files for use in external GIS
or visualization applications using `st_write` (sf package). Use in
ArcGIS, QGIS, Tableau, or any other application that reads shapefiles.

``` r
tarr_output_file <- "test_sf_files/tarr.shp"
if (!file.exists(tarr_output_file)) {
    st_write(tarr, tarr_output_file)
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
