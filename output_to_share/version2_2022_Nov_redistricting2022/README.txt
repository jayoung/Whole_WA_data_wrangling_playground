version2_2022_Nov_redistricting2022

looks pretty good, still some room for improvement

method:

got new (2022) redistricted boundary maps (.shp files from https://www.redistricting.wa.gov/district-maps-handouts

used 2020 census boundaries for zip codes (and for old LDs, just so we can view redistricting on the plots)

shrank each LD by 1km to avoid assigning zip codes that only overlap a tiny bit

get a list of all zip codes that overlap the shrunken LD

output list (LDredist2022_zip_codes_uncurated_v2_2022_Nov1.tsv), using similar format to Kelsey's google sheet
    Note - some zip codes didn't get a district assigned (see first column)

for each LD, make a plot of all the zip codes we assigned to that LD (see pdf files in LDredist_zip_codes_uncurated_v2_2022_Nov1_plots)

