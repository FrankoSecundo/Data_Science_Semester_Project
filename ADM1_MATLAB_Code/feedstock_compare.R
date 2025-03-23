library(ggplot2)
library(tidyverse)
library(reshape2)

theme_set(theme_bw(base_size = 16))

setwd("C:/Users/magic/Documents/Permalchemy_modelling/ADM1/Experimental/structures/feed_inputs/")

file.names <- list.files(path = "outputs/")

df <- read.csv("outputs/4_activated_sludge_2009.csv",header = TRUE,sep = ",")

dim(df)

mf <- data.frame(matrix(,ncol = dim(df)[2]))

colnames(mf) <- colnames(df)

mf$feed <- ""

setwd("C:/Users/magic/Documents/Permalchemy_modelling/ADM1/Experimental/structures/feed_inputs/outputs/")

for (i in file.names){
  
  t.data <- read.csv(i,header = TRUE,sep = ",")
  
  t.data$feed <- paste(i)
  
  mf <- rbind(mf,t.data)
  
  
}

mf <- mf[-1,]


mf2 <- mf %>% separate_wider_delim(feed, ".", names = c("feedstock", "csv"))


mf2 <- subset(mf2,select = -csv)

mf2.m <- melt(mf2, id.vars = c("time","feedstock"), variable.name = "Output", value.name = "Value")


ggplot(data = mf2.m,aes(x=time,y=Value))+geom_line(aes(colour = Output))+facet_grid(feedstock~.)

mf2_summary <- summary(mf2)

view(mf2_summary)

#######################

mf2.gas <- mf2.m %>% filter(Output=="q_gas")

feed.t <- c(10,30,50,70)

ggplot(data = mf2.gas,aes(x=time,y=Value))+geom_line(aes(colour = feedstock),size=.75)

ggplot(data = mf2.gas,aes(x=time,y=Value))+geom_line(aes(colour = feedstock),size=.75)+geom_vline(xintercept = feed.t,linetype='dotdash')+scale_color_brewer(palette = "Dark2")+ylab(bquote("Biogas Production L" ~d^ -1))+xlab("Time (days)")


###############################

mf2.grass <- mf2.m %>% filter(feedstock=="11_grass_silage")

ggplot(data = mf2.grass,aes(x=time,y=Value))+geom_line(aes(colour = "#fdae61"))+facet_wrap(Output~.,scales = "free")

gra.out <- unique(mf2.grass$Output)

g.o <- gra.out[c(1,2,3,16,17,18)]

ggplot(data = filter(mf2.grass,Output %in% g.o),aes(x=time,y=Value))+geom_line(aes(colour = Output),size=.75)+geom_vline(xintercept = feed.t,linetype='dotdash')+facet_wrap(Output~.,scales = "free")+ylab(bquote("mg" ~L^-1))+xlab("Time (days)")

g.o2 <- gra.out[c(4,5,6,7,19,20,21,22,31,35)]

ggplot(data = filter(mf2.grass,Output %in% g.o2),aes(x=time,y=Value))+geom_line(aes(colour = Output),size=.75)+geom_vline(xintercept = feed.t,linetype='dotdash')+facet_wrap(Output~.,scales = "free")+ylab(bquote("mg" ~L^-1))+xlab("Time (days)")



#######################


setwd("C:/Users/magic/Documents/Permalchemy_modelling/ADM1/Experimental/structures/feed_inputs/")

file.names <- list.files(path = "inputs_csv/")

ff <- read.csv("inputs_csv/10_corn_silage.csv",header = TRUE,sep = ",")

flf <- data.frame(matrix(,ncol = dim(ff)[2]))

colnames(flf) <- colnames(ff)

flf$feed <- ""


for (i in file.names){
  
  t.data <- read.csv(i,header = TRUE,sep = ",")
  
  t.data$feed <- paste(i)
  
  flf <- rbind(flf,t.data)
  
  
}

flf <- flf[-1,]


flf2 <- flf %>% separate_wider_delim(feed, ".", names = c("feedstock", "csv"))


flf2 <- subset(flf2,select = -csv)

flf2 <- flf2 %>% filter(q_in == 4 & time == 0)

cn <- colnames(flf2)

cn <- cn[c(3,4,5,6,7,8,15,16,17,37)]

flf3 <- flf2 %>% select(cn)

flf3.m <- melt(flf3, id.vars = c("feedstock"), variable.name = "Output", value.name = "Value")


ggplot(data = flf3.m)+geom_bar(mapping = aes(x=feedstock,y=Value,fill = Output),stat = 'identity',position = 'dodge')+ theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))

substr(flf3.m$Output,1,1)

flf3.m <- flf3.m %>% mutate(Fraction=ifelse(substr(Output,1,1)=="S","Soluble","Particulate"))

ggplot(data = flf3.m)+geom_bar(mapping = aes(x=feedstock,y=Value,fill = Output),stat = 'identity',position = 'dodge')+facet_grid(Fraction~.,scales = "free")+theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))+scale_fill_manual(values = c("#d53e4f","#f46d43","#fdae61","#f3e79b","#e6f598","#abdda4","#66c2a5","#3288bd","#5c53a5"))+ylab(bquote("kg COD" ~m^-3))
