load("C:/Users/Mike/Desktop/Dropbox/absences/workspace - data imported.RData")

####################################
# Transforming predictor variables #
# Goals: 0 skewness, range 0-1     #
####################################

head(dataENV)
colnames(data)

# goal: make a new data frame "dataENV_trans" 
# with transformed variables that make 0 skewness
# and variables range from 0 to 1 

# add latitude and longitude to the data frame (make a new data frame)
dataPREDICTORS <- cbind(dataENV,dataSPACE[,1:2])
head(dataPREDICTORS)


####################################
# check skewness for each variable # 
# with different transformations   # 
####################################
# load packages 
library(moments)

# untransformed
# loop through each variable 
for (i in 1:ncol(dataPREDICTORS)){
  temp <- skewness(dataPREDICTORS[,i])
  variable <- colnames(dataPREDICTORS)[i]
  print(c(variable,temp))
}

# log x + 1 transformed 
# loop through each variable 
for (i in 1:ncol(dataPREDICTORS)){
  temp <- skewness(log(dataPREDICTORS[,i]+1))
  variable <- colnames(dataPREDICTORS)[i]
  print(c(variable,temp))
}

# log x  transformed 
# loop through each variable 
for (i in 1:ncol(dataPREDICTORS)){
  temp <- skewness(log(dataPREDICTORS[,i]))
  variable <- colnames(dataPREDICTORS)[i]
  print(c(variable,temp))
}

# power transformed 
# power transformation will not work on variables <0 (waterbodies_1km, boatlaunch, dist_waterfowl)
library(car)
for (i in 1:ncol(dataPREDICTORS)){
  variable <- colnames(dataPREDICTORS)[i]
    
  if (variable == "nonFP_species_richness" | variable == "waterbodies_1km" | variable == "boatlaunch" | variable == "longitude"){
    print(paste("*** Skipped ",variable," values <=0",sep=""))
  }
  else {
    power <- powerTransform(dataPREDICTORS[,i])$lambda
    temp <- skewness(((dataPREDICTORS[,i])^power - 1) / power)
    print(c(variable,temp,power)) 
  }
}

####################################
# Creat the transformed data frame #
####################################
# add each variable with its best transformation (skewness closest to 0)
dataENV_trans <- cbind(log(dataPREDICTORS$surfacearea_ha + 1),
                       ((dataPREDICTORS$shoreline_development^-0.848911695 - 1) / -0.848911695),
                       ((dataPREDICTORS$depth_max_m^-0.025437664 - 1) / -0.025437664),
                       ((dataPREDICTORS$TOTP_avg^-0.015432306 - 1) / -0.015432306),
                       ((dataPREDICTORS$PH_avg^-0.691845256 - 1) / -0.691845256),
                       ((dataPREDICTORS$COND_avg^0.163450962 - 1) / 0.163450962),
                       ((dataPREDICTORS$ALK_avg^0.141677487 - 1) / 0.141677487),
                       ((dataPREDICTORS$secchi_avg^0.154358069 - 1) / 0.154358069),
                       log(dataPREDICTORS$waterbodies_1km + 1),
                       ((dataPREDICTORS$waterbodies_5km^0.208044927 - 1) / 0.208044927),
                       ((dataPREDICTORS$waterbodies_10km^0.209346202 - 1) / 0.209346202),
                       ((dataPREDICTORS$dist_waterfowl^0.261806542 - 1) / 0.261806542),
                       ((dataPREDICTORS$nearest_LM^0.344699109 - 1) / 0.344699109),
                       ((dataPREDICTORS$nearest_SP^0.614010651 - 1) / 0.614010651),
                       ((dataPREDICTORS$nearest_W^0.517930073977737 - 1) / 0.517930073977737),
                       ((dataPREDICTORS$nearest_any_FP^0.455384538 - 1) / 0.455384538),
                       ((dataPREDICTORS$latitude^-7.654166014 - 1) / -7.654166014),
                       dataPREDICTORS$longitude, 
                       dataPREDICTORS$boatlaunch,
                       log(dataPREDICTORS$nonFP_species_richness+1)
)

################################
# Range the variables from 0-1 # (data transformed for skewness)
################################
# make sure boatlaunch is the last column
# I don't want to "range" (transform to 0-1) this variable

library(scales)

for (i in 1:(ncol(dataENV_trans))){
  #print(i)
  dataENV_trans[,i] <- rescale(dataENV_trans[,i])
}

colnames(dataENV_trans) <- c("surfacearea_ha",
                             "shoreline_development",
                             "depth_max_m",
                             "TOTP_avg",
                             "PH_avg",
                             "COND_avg",
                             "ALK_avg",
                             "secchi_avg",
                             "waterbodies_1km",
                             "waterbodies_5km",
                             "waterbodies_10km",
                             "dist_waterfowl",
                             "nearest_LM",
                             "nearest_SP",
                             "nearest_W",
                             "nearest_any_FP",
                             "latitude",
                             "longitude",
                             "boatlaunch",
                             "nonFP_species_richness"
)

dataENV_trans <- as.data.frame(dataENV_trans)

##############################
# Remove outlier, then range #
##############################
library(scales)

dataPREDICTORS$waterbodies_5km <- NULL 

# remove outlier
dataPREDICTORS2 <- dataPREDICTORS[-129,]

# This will hold th results of re-scaling 
dataENV_scaled_out <- dataPREDICTORS2

# scale each column of the data frame  
for (i in 1:ncol(dataPREDICTORS)){
  dataENV_scaled_out[,i] <- rescale(dataPREDICTORS2[,i])
}

################################
# Range the variables from 0-1 # (data NOT transformed for skewness)
################################
# make sure boatlaunch is the last column
# I don't want to "range" (transform to 0-1) this variable

library(scales)

dataPREDICTORS$waterbodies_5km <- NULL 

dataENV_scaled <- dataPREDICTORS

for (i in 1:ncol(dataPREDICTORS)){
  #print(i)
  dataENV_scaled[,i] <- rescale(dataPREDICTORS[,i])
}


######################################
# Remove highly correlated variables #
######################################
dataENV_trans["waterbodies_5km"] <- NULL 
dataENV_scaled["waterbodies_5km"] <- NULL 

write.csv(dataENV_trans,"dataENV_trans.csv",row.names=FALSE)
write.csv(dataENV_scaled,"dataENV_scaled.csv",row.names=FALSE)
write.csv(dataENV_scaled,"dataENV_scaled_out.csv",row.names=FALSE)

#############################
# clean up when you're done #
#############################
rm(temp,i,power,variable,dataPREDICTORS)
  
  
  