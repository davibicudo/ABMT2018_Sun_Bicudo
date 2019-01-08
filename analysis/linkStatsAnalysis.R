
pacman::p_load("data.table", "sp", "rgdal")

# read link stats
linkStats_baseline <- fread("gzip -dc simulation_output_baseline/ITERS/it.100/100.linkstats.txt.gz")
linkStats_closedRoads <- fread("gzip -dc simulation_output_closedRoads/ITERS/it.100/100.linkstats.txt.gz")
linkStats_WTime <- fread("gzip -dc simulation_output_WTime/ITERS/it.100/100.linkstats.txt.gz")

# keep only relevant columns
cols <- c("LINK", "HRS7-8avg", "HRS17-18avg", "TRAVELTIME7-8avg", "TRAVELTIME17-18avg")
linkStats_baseline <- linkStats_baseline[,..cols]
linkStats_closedRoads <- linkStats_closedRoads[,..cols]
linkStats_WTime <- linkStats_WTime[,..cols]

# read buffer area and links
buffer1km <-  readOGR("GIS/buffer1km.geojson")
linksCut <- readOGR("GIS/linksCut.shp", stringsAsFactors = F)
linksClosed <- readOGR("GIS/closedLinks.geojson", stringsAsFactors = F)
buffer1km <- spTransform(buffer1km, CRS("+init=epsg:2154"))
proj4string(linksCut) <- CRS("+init=epsg:2154")
linksClosed <- spTransform(linksClosed, CRS("+init=epsg:2154"))

# filter links in buffer
linksBuffer <- linksCut[buffer1km, ]
linkIdsBuffer_baseline <- linksBuffer@data$ID
linkIdsBuffer_other <- subset(linksBuffer@data, !(ID %in% linksClosed$ID), select = "ID")$ID

# filter stats for links within buffer
linkStatsBuffer_baseline <- linkStats_baseline[LINK %in% linkIdsBuffer_baseline,]
linkStatsBuffer_closedRoads <- linkStats_closedRoads[LINK %in% linkIdsBuffer_other,]
linkStatsBuffer_WTime <- linkStats_WTime[LINK %in% linkIdsBuffer_other,]

# stats on links
summary(linkStatsBuffer_baseline)
summary(linkStatsBuffer_closedRoads)
summary(linkStatsBuffer_WTime)
