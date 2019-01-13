library(ggplot2)
library(reshape2)
library(plyr)

setwd("C:\\Users\\sunxi\\git\\ABMT2018_Sun_Bicudo\\analysis")

scor <- read.csv("scoreComparison.csv",sep = ";",row.names = NULL)
colnames(scor) <- c("personID","Baseline","Road Closure","Flexible Departure")
scor <- scor[,1:4]

scor_long <- melt(scor, na.rm = FALSE, id.vars = "personID", measure.vars = c("Baseline","Road Closure","Flexible Departure"))
colnames(scor_long) <- c("personID","Scenarios","Score")

box <- ggplot(scor_long, aes(x=Scenarios, y=Score, fill=Scenarios)) +
  geom_boxplot(outlier.shape=NA) +
  scale_y_continuous(limits = quantile(scor_long$Score, c(0.1, 0.89))) + 
  guides(fill=FALSE)
box

cscor <- ddply(scor_long, "Scenarios", summarise, Score.mean=mean(Score), Score.high =max(Score), Score.low = min(Score))
cscor


hist2 <- ggplot(scor_long, aes(x=Score, colour=Scenarios)) +
  geom_density() +
  geom_vline(data=cscor, aes(xintercept=Score.mean, colour=Scenarios, size=2),
             linetype="dashed", size=0.5)+
  scale_color_manual(values=c("red", "blue", "#00CCCC"))

hist2

