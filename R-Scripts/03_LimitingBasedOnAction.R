


GTthreeActions <- my_data[ which(my_data$action_count > 3), ]

smp_size <- floor(0.70 * nrow(GTthreeActions))

## set the seed to make your partition reproducible
set.seed(456)
train_ind <- sample(seq_len(nrow(GTthreeActions)), size = smp_size)
train <- GTthreeActions[train_ind, ]
test <- GTthreeActions[-train_ind, ]


# Create the tree.
tree.partisan_action <- ctree(
  Pass_Ind ~ CS_Partisan_Ind+action_count, 
  data = train)

summary(tree.partisan_action)
plot(tree.partisan_action)

#Evaluate against test set
test_pred1 <- predict(tree.partisan_action, newdata = test)
test_pred1 == test[8]
mean(test_pred1 == test[8])  


##Test Initial predictors
tree.bill_summary <- ctree(
  #  Pass_Ind ~ type+Pres_Party_Match+Senate_Party_Match+HouseOfR_Party_Match+CoSponsor_Count+CS_Partisan_Ind, 
  Pass_Ind ~ Pres_Party_Match+Senate_Party_Match+HouseOfR_Party_Match+CS_Partisan_Ind+CoSponsor_Count, 
  data = train)

test_pred2 <- predict(tree.bill_summary, newdata = test)
test_pred2 == test[8]
mean(test_pred2 == test[8])  

ModelStats <- data.frame(cbind(actuals=test[8], actionTree=test_pred1, summary=test_pred2))
write.csv(ModelStats, file = "C:/Users/Katie/Documents/AIT-582/ModelStats-LimitOnAction.csv")
