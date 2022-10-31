looks pretty good, still some room for improvement

method:

used 2020 census boundaries for LDs and zip codes
   - would love to update to post-redistricting boundaries, available here https://www.redistricting.wa.gov/district-maps-handouts

shrank each LD by 1km to avoid assigning zip codes that only overlap a tiny bit

get a list of all zip codes that overlap the shrunken LD

output list (LD_zip_codes_uncurated_v1_2022_Oct30.tsv), using similar format to Kelsey's google sheet
    Note - some zip codes didn't get a district assigned (see first column)

for each LD, make a plot of all the zip codes we assigned to that LD (see pdf files in LD_zip_codes_uncurated_v1_2022_Oct30_plots)

