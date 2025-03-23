library(ggplot2)
library(tidyverse)
library(reshape2)

theme_set(theme_bw())

dt <- read.csv("Simulink/ADM1_R4_Maize.csv",header = TRUE,sep = ",")

dt.m <- melt(dt,id=c("time")) 

fvariables <- c("X_ch","X_pr","X_li")

dt.f <- filter(dt.m,variable %in% fvariables)


ggplot(data = dt.f,aes(x=time,y=value,color = variable))+geom_line()


################### Reading in the feedstock inputs ####################


dtmz <- read.csv("Simulink/structures/feed_inputs/Maize.csv",header = TRUE,sep = ",")

dtmm <- read.csv("Simulink/structures/feed_inputs/Manure.csv",header = TRUE,sep = ",")

dtmz.m <- melt(dtmz,id=c("time"))

dtmm.m <- melt(dtmm,id=c("time"))

dtmz.m$feed <- paste("Maize")
dtmm.m$feed <- paste("Manure")

dta.m <- rbind(dtmz.m,dtmm.m)

# split

write.table(dta.m,file = "dtam.csv",sep = ",")


dta.ms <- read.csv("dtam.csv",sep = ",",header = TRUE)

ggplot(data = filter(dta.ms,qsX=="X"),aes(x=variable,y=log10(value),fill = feed))+geom_bar(stat = "identity",position = "dodge")
