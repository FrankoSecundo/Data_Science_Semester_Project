#### Creating individual input for each food waste #####


library(tidyverse)
library(dplyr)

theme_set(theme_bw(base_size = 16))


#load in the default input which will be the base template

inp <- read.csv(file = "Default_input.csv",sep = ",",header = TRUE)


#and bring in the foodwaste dataset

fwd <- read.csv(file = "Dataset/Food_waste_characterization.csv",sep = ",",header = TRUE)

# we will mutate the columns to be as percentages

fwd <- fwd %>% mutate(Fat.Perc=Fat.Perc/100) %>% mutate(Protein.Perc=Protein.Perc/100) %>% mutate(Carbohydrate.Perc=Carbohydrate.Perc/100) %>% mutate(TS.Perc=TS.Perc/100) %>% mutate(VS.Perc=VS.Perc/100)

####### creating individual input files for event feeding ###########

# set the input mass in grams

inputmass <- 1000

for(i in 1:nrow(fwd)){
  
  TS <- inputmass * fwd[i,7]
  VS <- TS * fwd[i,8]
  CP <- VS * fwd[i,13]
  PP <- VS * fwd[i,12]
  LP <- VS * fwd[i,11]
  
  inp.temp <- inp
  
  inp.temp$X_ch <- CP
  inp.temp$X_pr <- PP
  inp.temp$X_li <- LP
  
  fname <- paste(fwd[i,4],".csv",sep = "")
  setwd("C:/Users/magic/Documents/Data_Science_Semester_Project/Data_Science_Semester_Project/Dataset/Individual_inputs")
  
  write.csv(inp.temp,file = fname,row.names = FALSE)
  
}

################# creating individual files for sequential feeding #############

setwd("C:/Users/magic/Documents/Data_Science_Semester_Project/Data_Science_Semester_Project/")

#load in the default input for continuous feed which will be the base template

inf <- read.csv(file = "Default_input_continuous.csv",sep = ",",header = TRUE)

# set the input mass in grams

VSmass <- 300

for(i in 1:nrow(fwd)){
  
  VS <- VSmass
  CP <- VS * fwd[i,13]
  PP <- VS * fwd[i,12]
  LP <- VS * fwd[i,11]
  
  inf.temp <- inf
  
  inf.temp$X_ch <- CP
  inf.temp$X_pr <- PP
  inf.temp$X_li <- LP
  
  fname <- paste(fwd[i,4],".csv",sep = "")
  setwd("C:/Users/magic/Documents/Data_Science_Semester_Project/Data_Science_Semester_Project/Dataset/Individual_inputs_continuous/")
  
  write.csv(inf.temp,file = fname,row.names = FALSE)
  
}

############### Plotting Output #######################


############## Event #######################

# creating dummy dataframe

df2 <- data.frame(time=c('0'),q_gas=c('0'),Food.Wastes.Clean=c('0'))


# go to where the files are

setwd("C:/Users/magic/Documents/Data_Science_Semester_Project/Data_Science_Semester_Project/ADM1/Experimental/Output/Event/")

names <- list.files(path = ".")

for(i in names){
  ot <- read.csv(file = i ,sep = ",",header = TRUE)
  ot.f <- ot %>% select(time,q_gas)
  ot.f$Food.Wastes.Clean <- i
  
  df2 <- rbind(df2,ot.f)
  
}

df2$Food.Wastes.Clean <- gsub(".csv","",as.character(df2$Food.Wastes.Clean))
df2$Food.Wastes.Clean <- gsub("O_","",as.character(df2$Food.Wastes.Clean))

df2 <- df2 %>% filter(Food.Wastes.Clean != 0)

#### plot

df2$time <- as.numeric(df2$time)
df2$q_gas <- as.numeric(df2$q_gas)

df2.b <- left_join(df2,fwd,by="Food.Wastes.Clean")

ggplot(data = df2.b)+geom_point(aes(x=time,y=q_gas,color = Group),show.legend = FALSE)+facet_wrap(Group~.,scales = "free")


############## Continuous ###################

# creating dummy dataframe

df1 <- data.frame(time=c('0'),q_gas=c('0'),Food.Wastes.Clean=c('0'))


# go to where the files are

setwd("C:/Users/magic/Documents/Data_Science_Semester_Project/Data_Science_Semester_Project/ADM1/Experimental/Output/Continuous/")

names <- list.files(path = ".")

for(i in names){
  ot <- read.csv(file = i ,sep = ",",header = TRUE)
  ot.f <- ot %>% select(time,q_gas)
  ot.f$Food.Wastes.Clean <- i
  
  df1 <- rbind(df1,ot.f)
  
}

df1$Food.Wastes.Clean <- gsub(".csv","",as.character(df1$Food.Wastes.Clean))
df1$Food.Wastes.Clean <- gsub("O_","",as.character(df1$Food.Wastes.Clean))

df1 <- df1 %>% filter(Food.Wastes.Clean != 0)

#### plot

df1$time <- as.numeric(df1$time)
df1$q_gas <- as.numeric(df1$q_gas)

# join with the other data 

df1.b <- left_join(df1,fwd,by="Food.Wastes.Clean")

ggplot(data = df1.b)+geom_point(aes(x=time,y=q_gas,color = Group),show.legend = FALSE)+facet_wrap(Group~.)

 write.csv(fwd,"C:/Users/magic/Documents/Data_Science_Semester_Project/Data_Science_Semester_Project/Dataset/Food_Waste_Characterization_perc.csv",row.names = FALSE)


