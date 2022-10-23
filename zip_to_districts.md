get zip to district tables
================
Janet Young
2022-10-23

Use the `tigris` package to get the boundaries of various regions. This
will take a few minutes.

``` r
WA_state_LDs <- state_legislative_districts("WA")
```

    ## Retrieving data for the year 2020

``` r
WA_state_CongDists <- congressional_districts("WA")
```

    ## Retrieving data for the year 2020

``` r
WA_state_ZipCodes <-  zctas("WA") 
```

    ## Retrieving data for the year 2020

``` r
#WA_counties <- counties("WA")
#WA_state_VotingDists <- voting_districts("WA") 

## something about this code seems to use a lot of memory, so I'm doing GC() quite often
gc(verbose = FALSE)
```

    ##             used  (Mb) gc trigger   (Mb) limit (Mb)  max used   (Mb)
    ## Ncells   1838450  98.2    3081367  164.6         NA   2342309  125.1
    ## Vcells 106033569 809.0  231670194 1767.6      16384 209224962 1596.3

``` r
#### some stats on each object
# format(object.size(WA_counties), units = "auto")
#  2Mb
# format(object.size(WA_state_LDs), units = "auto")
# 2.8Mb
# format(object.size(WA_state_CongDists), units = "auto")
# 1.3Mb
# format(object.size(WA_state_VotingDists), units = "auto")
# 29 Mb
# format(object.size(WA_state_ZipCodes), units = "auto")
# 813.2Mb
# 
# dim(WA_counties)
# # [1] 39 18
# dim(WA_state_LDs)
# # [1] 49 13
# dim(WA_state_CongDists)
# # [1] 10 13
# dim(WA_state_VotingDists) 
# # [1] 7434   15
# dim(WA_state_ZipCodes) 
# # [1] 33791    10 
```

We can use the `st_join` function from the `sf` package to figure out
which regions overlap each other. Result is a merged table (a bit like
result of `left_join`).

We can use `st_join` in two ways, using the `join` option (described
[here](https://crd230.github.io/lab3.html#within)): +
`join=st_intersects` if a zip code touches a district, we consider them
together. Many zip codes touch \>1 district + `join=st_within` a zip
code must be totally within a district to be counted

Let’s use zip codes and congressional districts as an example (there’s
10 congressional districts in WA, compared to 49 LDs).

First let’s try the `join = st_intersects` option and show the first few
lines:

``` r
zipCodes_by_CongDist_intersect <- st_join(WA_state_ZipCodes, 
                                WA_state_CongDists, 
                                join = st_intersects, 
                                left=FALSE)
gc(verbose = FALSE)
```

    ##             used  (Mb) gc trigger   (Mb) limit (Mb)  max used   (Mb)
    ## Ncells   1870789 100.0    3081367  164.6         NA   3081367  164.6
    ## Vcells 106104945 809.6  231670194 1767.6      16384 209717473 1600.1

``` r
# turn that into a tibble
zipCodes_by_CongDist_intersect_plain <- zipCodes_by_CongDist_intersect %>%
    select(ZCTA5CE20,NAMELSAD) %>%
    as_tibble() %>%
    select(-geometry) %>% 
    arrange(NAMELSAD) %>% 
    rename(congressional_district=NAMELSAD) %>% 
    rename(zip_code=ZCTA5CE20)

zipCodes_by_CongDist_intersect_plain %>% 
    head(6) %>% 
    kable() %>% 
    kable_styling(font_size = 12)
```

<table class="table" style="font-size: 12px; margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
zip_code
</th>
<th style="text-align:left;">
congressional_district
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
98007
</td>
<td style="text-align:left;">
Congressional District 1
</td>
</tr>
<tr>
<td style="text-align:left;">
98024
</td>
<td style="text-align:left;">
Congressional District 1
</td>
</tr>
<tr>
<td style="text-align:left;">
98122
</td>
<td style="text-align:left;">
Congressional District 1
</td>
</tr>
<tr>
<td style="text-align:left;">
98220
</td>
<td style="text-align:left;">
Congressional District 1
</td>
</tr>
<tr>
<td style="text-align:left;">
98296
</td>
<td style="text-align:left;">
Congressional District 1
</td>
</tr>
<tr>
<td style="text-align:left;">
98014
</td>
<td style="text-align:left;">
Congressional District 1
</td>
</tr>
</tbody>
</table>

This looks great. We could export the
`zipCodes_by_CongDist_intersect_plain` as a csv files and actually use
it, but there’s an issue we should deal with first: some zip codes are
in \>1 LD using the intersects method:

``` r
zipCodes_by_CongDist_intersect_plain %>% 
    count(zip_code) %>% 
    rename(num_districts_per_zip=n) %>% 
    count(num_districts_per_zip) %>% 
    rename(num_zip_codes=n) %>% 
    kable() %>% 
    kable_styling(font_size = 12)
```

<table class="table" style="font-size: 12px; margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:right;">
num_districts_per_zip
</th>
<th style="text-align:right;">
num_zip_codes
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
458
</td>
</tr>
<tr>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
161
</td>
</tr>
<tr>
<td style="text-align:right;">
3
</td>
<td style="text-align:right;">
28
</td>
</tr>
</tbody>
</table>

Now let’s try the `join = st_within` option - now all districts are in 1
zip code. BUT there are a lot of zip codes missing - I think it’s
ignoring the ones in \>1 district.

``` r
zipCodes_by_CongDist_within <- st_join(WA_state_ZipCodes, 
                                WA_state_CongDists, 
                                join = st_within, 
                                left=FALSE)
gc(verbose = FALSE)
```

    ##             used  (Mb) gc trigger   (Mb) limit (Mb)  max used   (Mb)
    ## Ncells   1925299 102.9    3081367  164.6         NA   3081367  164.6
    ## Vcells 106231129 810.5  231670194 1767.6      16384 210109975 1603.1

``` r
# turn that into a tibble
zipCodes_by_CongDist_within_plain <- zipCodes_by_CongDist_within %>%
    select(ZCTA5CE20,NAMELSAD) %>%
    as_tibble() %>%
    select(-geometry) %>% 
    arrange(NAMELSAD) %>% 
    rename(congressional_district=NAMELSAD) %>% 
    rename(zip_code=ZCTA5CE20)
```

``` r
zipCodes_by_CongDist_within_plain %>% 
    count(zip_code) %>% 
    rename(num_districts_per_zip=n) %>% 
    count(num_districts_per_zip) %>% 
    rename(num_zip_codes=n) %>% 
    kable() %>% 
    kable_styling(font_size = 12)
```

<table class="table" style="font-size: 12px; margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:right;">
num_districts_per_zip
</th>
<th style="text-align:right;">
num_zip_codes
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
370
</td>
</tr>
</tbody>
</table>

Which zip codes were in 3 districts when we use intersect? I’ll show the
first 8

``` r
zipCodes_by_CongDist_intersect_plain %>% 
    count(zip_code) %>% 
    filter(n==3) %>% 
    head(8) %>% 
    kable() %>% 
    kable_styling(font_size = 12)
```

<table class="table" style="font-size: 12px; margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
zip_code
</th>
<th style="text-align:right;">
n
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
98001
</td>
<td style="text-align:right;">
3
</td>
</tr>
<tr>
<td style="text-align:left;">
98008
</td>
<td style="text-align:right;">
3
</td>
</tr>
<tr>
<td style="text-align:left;">
98028
</td>
<td style="text-align:right;">
3
</td>
</tr>
<tr>
<td style="text-align:left;">
98033
</td>
<td style="text-align:right;">
3
</td>
</tr>
<tr>
<td style="text-align:left;">
98036
</td>
<td style="text-align:right;">
3
</td>
</tr>
<tr>
<td style="text-align:left;">
98039
</td>
<td style="text-align:right;">
3
</td>
</tr>
<tr>
<td style="text-align:left;">
98040
</td>
<td style="text-align:right;">
3
</td>
</tr>
<tr>
<td style="text-align:left;">
98052
</td>
<td style="text-align:right;">
3
</td>
</tr>
</tbody>
</table>

One of those zip codes is 98040, which google maps tells me is Mercer
Island

Mercer Island is only in dist 9 according to
[wikipedia](https://en.wikipedia.org/wiki/Washington%27s_9th_congressional_district)
and doesn’t even touch 7 and 1

Might be something to do with how the lake is accounted for. I suspect
there’s a way to deal with it - see [this
doc](https://crd230.github.io/lab3.html#within)

``` r
zipCodes_by_CongDist_intersect_plain %>% 
    filter(zip_code=="98040")
```

    ## # A tibble: 3 × 2
    ##   zip_code congressional_district  
    ##   <chr>    <chr>                   
    ## 1 98040    Congressional District 1
    ## 2 98040    Congressional District 7
    ## 3 98040    Congressional District 9

Let’s try `largest=TRUE` in the `st_join` function - I think that
chooses the single region that has the biggest overlap. What happens?

It runs very slowly, and consumes a lot of memory, and is not finishing.
For now I won’t run this code. I want to test it either in a new R
session, or perhaps with a smaller test dataset.

I can also probably help this along by using a separate R session to
create and save the intersection objects

``` r
zipCodes_by_CongDist_intersectLargest <- st_join(WA_state_ZipCodes, 
                                WA_state_CongDists, 
                                join = st_intersects, 
                                largest=TRUE,
                                left=FALSE)
gc(verbose = FALSE)

# turn that into a tibble
zipCodes_by_CongDist_intersectLargest_plain <- zipCodes_by_CongDist_intersectLargest %>%
    select(ZCTA5CE20,NAMELSAD) %>%
    as_tibble() %>%
    select(-geometry) %>% 
    arrange(NAMELSAD) %>% 
    rename(congressional_district=NAMELSAD) %>% 
    rename(zip_code=ZCTA5CE20)

zipCodes_by_CongDist_intersectLargest_plain %>% 
    count(zip_code) %>% 
    rename(num_districts_per_zip=n) %>% 
    count(num_districts_per_zip) %>% 
    rename(num_zip_codes=n) %>% 
    kable() %>% 
    kable_styling(font_size = 12)
```

What happened to Mercer Island?

``` r
zipCodes_by_CongDist_intersectLargest_plain %>%
    filter(zip_code=="98040")
```
