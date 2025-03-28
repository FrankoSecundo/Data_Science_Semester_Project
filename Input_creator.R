#### Creating individual input for each food waste #####


library(tidyverse)
library(dplyr)

theme_set(theme_bw(base_size = 16))

color = grDevices::colors()[grep('gr(a|e)y', grDevices::colors(), invert = T)]

pal.n20 <- sample(color, 20)


#load in the default input which will be the base template

inp <- read.csv(file = "Default_input_new.csv",sep = ",",header = TRUE)


#and bring in the foodwaste dataset

fwd <- read.csv(file = "Dataset/Food_waste_characterization.csv",sep = ",",header = TRUE)

# we will mutate the columns to be as percentages

fwd <- fwd %>% mutate(Fat.Perc=Fat.Perc/100) %>% mutate(Protein.Perc=Protein.Perc/100) %>% mutate(Carbohydrate.Perc=Carbohydrate.Perc/100) %>% mutate(TS.Perc=TS.Perc/100) %>% mutate(VS.Perc=VS.Perc/100)

####### creating individual input files for event feeding ###########

# set the input mass in grams

inputmass <- 10

for(i in 1:nrow(fwd)){
  
  # TS <- inputmass * fwd[i,7]
  # VS <- TS * fwd[i,8] this is the old part commented out now we will be operating directly from VS mass
  VS <- inputmass
  CP <- VS * fwd[i,13]
  PP <- VS * fwd[i,12]
  LP <- VS * fwd[i,11]
  
  inp.temp <- inp
  
  inp.temp$X_ch <- CP
  inp.temp$X_pr <- PP
  inp.temp$X_li <- LP
  
  fname <- paste(fwd[i,4],".csv",sep = "")
  setwd("C:/Users/magic/Documents/Data_Science_Semester_Project/Data_Science_Semester_Project/Dataset/Individual_inputs_masscor")
  
  write.csv(inp.temp,file = fname,row.names = FALSE)
  
}

################# creating individual files for sequential feeding #############

setwd("C:/Users/magic/Documents/Data_Science_Semester_Project/Data_Science_Semester_Project/")

#load in the default input for continuous feed which will be the base template

inf <- read.csv(file = "Default_input_continuous_new.csv",sep = ",",header = TRUE)

# set the input mass in grams

VSmass <- 74

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
  setwd("C:/Users/magic/Documents/Data_Science_Semester_Project/Data_Science_Semester_Project/Dataset/Individual_inputs_continuous_masscor/")
  
  write.csv(inf.temp,file = fname,row.names = FALSE)
  
}

############### Plotting Output #######################


############## Event #######################

# creating dummy dataframe

df2 <- data.frame(time=c('0'),q_gas=c('0'),Food.Wastes.Clean=c('0'))


# go to where the files are

setwd("C:/Users/magic/Documents/Data_Science_Semester_Project/Data_Science_Semester_Project/ADM1/Experimental/Output/Event_masscor/")

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

##### finding cumulative product

df2.bt <- df2.b  %>% group_by(Food.Wastes.Clean) %>% mutate(diff = time - lag(time, default = first(time))) %>% mutate(gas_prod_L = time*q_gas)

df2.gp <- df2.bt %>% select(Food.Wastes.Clean,Group,gas_prod_L)

df2.gps <- df2.gp %>% group_by(Food.Wastes.Clean,Group) %>% summarise(sum=sum(gas_prod_L),mean=mean(gas_prod_L))


ggplot(data = df2.gps)+geom_bar(mapping = aes(x=Food.Wastes.Clean,y=sum,fill = Group),stat = 'identity')+facet_wrap(Group~.,scales = "free_x")

df2.gps <- df2.gps %>% mutate(production_L_g_VS=sum/10000)

#### Box plot

ggplot(data = df2.gps)+geom_boxplot(mapping = aes(x=Group,y=production_L_g_VS,fill = Group),color="black")+scale_fill_manual(values = pal.n20)


############## Continuous ###################

# creating dummy dataframe

df1 <- data.frame(time=c('0'),q_gas=c('0'),Food.Wastes.Clean=c('0'))


# go to where the files are

setwd("C:/Users/magic/Documents/Data_Science_Semester_Project/Data_Science_Semester_Project/ADM1/Experimental/Output/Continuous_masscor/")

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
 
 
df1.bt <- df1.b  %>% group_by(Food.Wastes.Clean) %>% mutate(diff = time - lag(time, default = first(time))) %>% mutate(gas_prod_L = time*q_gas)

df1.gp <- df1.bt %>% select(Food.Wastes.Clean,Group,gas_prod_L)

df1.gps <- df1.gp %>% group_by(Food.Wastes.Clean,Group) %>% summarise(sum=sum(gas_prod_L),mean=mean(gas_prod_L))


ggplot(data = df1.gps)+geom_bar(mapping = aes(x=Food.Wastes.Clean,y=sum,fill = Group),stat = 'identity')+facet_wrap(Group~.,scales = "free_x")

df1.gps <- df1.gps %>% mutate(production_L_g_VS=sum/37370)

### box plots might be good visual

ggplot(data = df1.gps)+geom_boxplot(mapping = aes(x=Group,y=production_L_g_VS,fill = Group),color="black")+scale_fill_manual(values = pal.n20)
