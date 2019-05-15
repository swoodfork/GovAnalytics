#First copy data from excel
my_data <- read.table(file = "C:/Users/Katie/Documents/AIT-582/2019-05-04-DataExport.csv", 
                      sep = ",", header=TRUE)


#Convert Factors to numerics
my_data$Prcnt_Senators_In_Same_Party <- as.numeric(as.character(my_data$Prcnt_Senators_In_Same_Party))
my_data$Prcnt_HouseOfR_In_Same_Party <- as.numeric(as.character(my_data$Prcnt_Senators_In_Same_Party))
my_data$CoSponsor_Count <- as.numeric(as.character(my_data$CoSponsor_Count))
my_data$Rep_Count <- as.numeric(as.character(my_data$Rep_Count))
my_data$Dec_Count <- as.numeric(as.character(my_data$Dec_Count))
my_data$Partisan_ind <- as.numeric(as.character(my_data$Partisan_ind))


##Simple Linear Models
simple.PresMatch = lm(Pass_Ind~Pres_Party_Match, data=my_data)
summary(simple.PresMatch)

simple.SenateMatch = lm(Pass_Ind~Senate_Party_Match, data=my_data)
summary(simple.PresMatch)

simple.Prcnt_Senators_In_Same_Party = lm(Pass_Ind~Prcnt_Senators_In_Same_Party, data=my_data)
summary(simple.Prcnt_Senators_In_Same_Party)

simple.HouseOfRMatch = lm(Pass_Ind~HouseOfR_Party_Match, data=my_data)
summary(simple.HouseOfRMatch)

simple.Prcnt_HouseOfR_In_Same_Party = lm(Pass_Ind~Prcnt_HouseOfR_In_Same_Party, data=my_data)
summary(simple.Prcnt_HouseOfR_In_Same_Party)


simple.CoSponsor_Count = lm(Pass_Ind~CoSponsor_Count, data=my_data)
summary(simple.CoSponsor_Count)

simple.Rep_Count = lm(Pass_Ind~Rep_Count, data=my_data)
summary(simple.Rep_Count)

simple.Dem_Count = lm(Pass_Ind~Dem_Count, data=my_data)
summary(simple.Dem_Count)

simple.Partisan_Ind= lm(Pass_Ind~Partisan_Ind, data=my_data)
summary(simple.Partisan_Ind)



###Split data frame into training and testing sets

## 60% of the sample size
smp_size <- floor(0.60 * nrow(my_data))

## set the seed to make your partition reproducible
set.seed(123)
train_ind <- sample(seq_len(nrow(my_data)), size = smp_size)

train <- my_data[train_ind, ]
test <- my_data[-train_ind, ]


#### Make multi-predictor linear model
multi.fit = lm(Pass_Ind~Pres_Party_Match+Senate_Party_Match+Prcnt_Senators_In_Same_Party+HouseOfR_Party_Match+Prcnt_HouseOfR_In_Same_Party+CoSponsor_Count+Rep_Count+Dem_Count+Partisan_Ind, data=train)
summary(multi.fit)

##how did it do? 
anova(multi.fit)

distPred <- predict(multi.fit, test)
actuals_preds <- data.frame(cbind(actuals=test$Pass_Ind, predicteds=distPred))

