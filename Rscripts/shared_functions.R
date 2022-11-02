## we'll project into this coordinate system ("NAD83(2011) / Washington North", ID=6596)
chosenCoordReferenceSystem <- 6596

## function to project the coords of any sf object onto the reference system of our choice
projectCoords <- function(regions, use_crs = chosenCoordReferenceSystem)  {
    projected <- st_transform(regions, crs = use_crs)
    return(projected)
}


### makeWideTable: a function to export a zip-to-district csv in a format similar to the one in Kelsey's LD-to-zip sheet
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

