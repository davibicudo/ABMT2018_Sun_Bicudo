
pacman::p_load("data.table", "sp", "rgdal", "ggplot2", "dplyr")

# read link stats
linkStats_baseline <- fread("gzip -dc simulation_output_baseline/ITERS/it.100/100.linkstats.txt.gz")
linkStats_closedRoads <- fread("gzip -dc simulation_output_closedRoads/ITERS/it.100/100.linkstats.txt.gz")
linkStats_WTime <- fread("gzip -dc simulation_output_WTime/ITERS/it.100/100.linkstats.txt.gz")

# keep only relevant columns
cols <- c("LINK", names(linkStats_baseline)[grepl("avg", names(linkStats_baseline))])
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
linkStatsBuffer_baseline <- linkStats_baseline[LINK %in% linkIdsBuffer_other,!"LINK", with=FALSE]
linkStatsBuffer_closedRoads <- linkStats_closedRoads[LINK %in% linkIdsBuffer_other,!"LINK", with=FALSE]
linkStatsBuffer_WTime <- linkStats_WTime[LINK %in% linkIdsBuffer_other,!"LINK", with=FALSE]

# hourly averages
hourlyAvg <- data.frame(baseline=colMeans(linkStatsBuffer_baseline), 
                        closedRoads=colMeans(linkStatsBuffer_closedRoads), 
                        WTime=colMeans(linkStatsBuffer_WTime))
write.csv(hourlyAvg, file="linkAverages.csv")

# volume stats on links (boxplot)
## Outliers removed to improve visualization.
MPH <- c(linkStatsBuffer_baseline$`HRS7-8avg`, linkStatsBuffer_closedRoads$`HRS7-8avg`, linkStatsBuffer_WTime$`HRS7-8avg`)
APH <- c(linkStatsBuffer_baseline$`HRS17-18avg`, linkStatsBuffer_closedRoads$`HRS17-18avg`, linkStatsBuffer_WTime$`HRS17-18avg`)
OPH <- c(linkStatsBuffer_baseline$`HRS10-11avg`, linkStatsBuffer_closedRoads$`HRS10-11avg`, linkStatsBuffer_WTime$`HRS10-11avg`)
NTH <- c(linkStatsBuffer_baseline$`HRS21-22avg`, linkStatsBuffer_closedRoads$`HRS21-22avg`, linkStatsBuffer_WTime$`HRS21-22avg`)
labs <- c("Morning-peak hour (7-8h)", "Afternoon-peak hour (17-18h)", "Off-peak hour (10-11h)", "Night-time hour (21-22h)")
DF <- data.frame(
  x=c(MPH, APH, OPH, NTH),
  y=rep(labs, each=length(MPH)),
  z=c(rep("baseline", nrow(linkStatsBuffer_baseline)), 
      rep("closed roads", nrow(linkStatsBuffer_closedRoads)), 
      rep("departure innovation", nrow(linkStatsBuffer_WTime))),
  stringsAsFactors = T
)
#DF$z <- factor(DF$z, levels = c("departure innovation", "closed roads", "baseline"), ordered=T)
ggplot(DF, aes(y, x, fill=z)) + 
  geom_boxplot(outlier.shape=NA) +
  scale_y_continuous(limits = quantile(DF$x, c(0.1, 0.89))) + 
  scale_x_discrete(limits = labs) +
  #coord_flip() + 
  theme_minimal() +
  ylab("Link volume (1% scenario)") +
  theme(axis.title.x=element_blank(), 
        legend.title=element_blank(), legend.position = "bottom",
        axis.text.x = element_text(angle = 45, hjust = 1),
        text = element_text(size=16),
        plot.margin=margin(2,2,2,2,"cm")) +
  guides(fill=guide_legend(reverse=F))

# speed stats on links (boxplot)
## Outliers removed to improve visualization.
MPH2 <- c(linkStatsBuffer_baseline$`TRAVELTIME7-8avg`, linkStatsBuffer_closedRoads$`TRAVELTIME7-8avg`, linkStatsBuffer_WTime$`TRAVELTIME7-8avg`)
APH2 <- c(linkStatsBuffer_baseline$`TRAVELTIME17-18avg`, linkStatsBuffer_closedRoads$`TRAVELTIME17-18avg`, linkStatsBuffer_WTime$`TRAVELTIME17-18avg`)
OPH2 <- c(linkStatsBuffer_baseline$`TRAVELTIME10-11avg`, linkStatsBuffer_closedRoads$`TRAVELTIME10-11avg`, linkStatsBuffer_WTime$`TRAVELTIME10-11avg`)
NTH2 <- c(linkStatsBuffer_baseline$`TRAVELTIME21-22avg`, linkStatsBuffer_closedRoads$`TRAVELTIME21-22avg`, linkStatsBuffer_WTime$`TRAVELTIME21-22avg`)
labs <- c("Morning-peak hour (7-8h)", "Afternoon-peak hour (17-18h)", "Off-peak hour (10-11h)", "Night-time hour (21-22h)")
DF2 <- data.frame(
  x=c(MPH2, APH2, OPH2, NTH2),
  y=rep(labs, each=length(MPH2)),
  z=c(rep("baseline", nrow(linkStatsBuffer_baseline)), 
      rep("closed roads", nrow(linkStatsBuffer_closedRoads)), 
      rep("departure innovation", nrow(linkStatsBuffer_WTime))),
  stringsAsFactors = T
)
#DF2$z <- factor(DF2$z, levels = c("departure innovation", "closed roads", "baseline"), ordered=T)
ggplot(DF2, aes(y, x, fill=z)) + 
  geom_boxplot(outlier.shape=NA) +
  scale_y_continuous(limits = quantile(DF$x, c(0.1, 0.89))) + 
  scale_x_discrete(limits = labs) +
  #coord_flip() + 
  theme_minimal() +
  ylab("Link speed (m/s)") +
  theme(axis.title.x=element_blank(), 
        legend.title=element_blank(), legend.position = "bottom",
        axis.text.x = element_text(angle = 45, hjust = 1),
        text = element_text(size=16),
        plot.margin=margin(2,2,2,2,"cm")) +
  guides(fill=guide_legend(reverse=F))

