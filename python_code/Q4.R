#load packages if needed
library(aod)
library(car)
library(ggplot2)
library(ggplotgui)
library(lmtest)
library(pROC)
library(psych)
library(fastDummies)

#LOAD file
HBAT<- readRDS(file.choose())

#4.	Build a model to predict StratAlliance by PurchaseLevel, Customer, Size, and Satisfaction.
HBAT_4<-subset.data.frame(HBAT, select=c("StratAlliance","PurchaseLevel","Customer","Size","Satisfaction"))

# make DV into 1/0, and make nominal IVs into Dummy Variables
HBAT_4$StratAlliance <- as.numeric(HBAT_4$StratAlliance == "Yes")

HBAT_4<- dummy_cols(HBAT_4)
HBAT_4 <- HBAT_4[, -c(3,4)]

names(HBAT_4)

#outliers, colinearity 
cor(HBAT_4)
ggplot_shiny(HBAT_4) #CHECKING OUTLIERS 
mvnObj<- mvn(
  data=HBAT_4[,2:3],
  mvnTest="hz",
  univariateTest = "AD",
  multivariatePlot = "qq",
  multivariateOutlierMethod = "adj",
  showOutliers = TRUE,
  showNewData = TRUE)

outliers <- (mvnObj$multivariateOutliers)[ , 1]
outliers <- as.numeric(outliers)
HBAT_4_clean <- HBAT_4[-c(outliers), ] #so if there are outliers use "HBAT_200c" as the data below instead of the original data. If there were no outliers, this line will result in an empty dataframe.
#View(HBAT_4_clean)

#2nd check multivariate outliers
cor(HBAT_4_clean)
mvnObj2<- mvn(
  data=HBAT_4_clean[,2:3],
  mvnTest="hz",
  univariateTest = "AD",
  multivariatePlot = "qq",
  multivariateOutlierMethod = "adj",
  showOutliers = TRUE,
  showNewData = TRUE)


#linear regression
linReg<- lm( StratAlliance ~ PurchaseLevel, HBAT_4_clean)
summary(linReg)
I1 <- data.frame(PurchaseLevel = 51.1)
I2 <- data.frame(PurchaseLevel =44.1)
I3 <- data.frame(PurchaseLevel = 50.1)
ex1 <- rbind(I1, I2, I3)
predict(linReg, ex1, interval="confid")

#ggplot_shiny(HBAT_4_clean)

#Binary Log---- 
LogMod <- glm(
  StratAlliance~PurchaseLevel, 
  data=HBAT_4_clean, family="binomial")
summary(LogMod)

#
#Test overall model----
anova(LogMod, test="Chisq")
lrtest(LogMod)

##Coefficients----
LogMod$coefficients

#Test Coefficient
wald.test(b=coef(LogMod), Sigma=vcov(LogMod), Terms=1)
wald.test(b=coef(LogMod), Sigma=vcov(LogMod), Terms=2)
#
##Odds of StratAlliance ----
#ln(Odds)
coef(LogMod)
#Odds sleeping compared to non-prob sleeping
exp(coef(LogMod))
#Odds no-prob sleeping compared to prob sleeping
1/exp(coef(LogMod))


#
#Estimated Probability of StratAlliance
HBAT_4_clean$PredAlliance <- predict(LogMod, type="response")
#View(HBAT_4_clean)
HBAT_4_clean$PredProb <- 0
HBAT_4_clean$PredProb[HBAT_4_clean$PredAlliance >= .5] <- 1
#View(HBAT_4_clean)


#confusion matrix
xtab <- table(HBAT_4_clean$StratAlliance,HBAT_4_clean$PredProb)
xtab
# percnt improvement
#how many wrong with no model
wrongNM <- min(rowSums(xtab))
#how many wrong with model
wrongWM <- sum(xtab)-sum(diag(xtab))
#percent improvement in error rate
(wrongNM-wrongWM)/wrongNM

#kappa
Alliance_kappa <- cohen.kappa(xtab)
Alliance_kappa$kappa

#ROC 
roc <- roc(HBAT_4_clean$StratAlliance,HBAT_4_clean$PurchaseLevel, direction=">") #creates an object with all sorts of diagnostics including sensitivities and specificities
plot(roc)


#MIXED STEP-WISE REGRESSION
#define intercept-only model
intercept_only2 <- glm(StratAlliance ~ 1, 
                      data=HBAT_4_clean, family="binomial")
#StratAlliance ~ 1 means StratAlliance probably estimated by 1


#define model with all predictors
all2 <- glm(StratAlliance ~ PurchaseLevel + Satisfaction + 
              Customer_lessthan1yr + Customer_btwn_1_5yr +Customer_Over5yr + Size_Small+Size_Large, 
            data = HBAT_4_clean, family="binomial")
summary(all2)

#perform mixed stepwise regression 
both2<- step(intercept_only2, direction='both', scope=formula(all2), trace=0)

#view results of mixed stepwise regression
both2$anova
summary(both2)

#view final model 
# this model results are LOGITS, we need to turn them into exp
both2$coefficients

#odds ratios
#interpretations!!!***: for every unit increase (binary 0 to 1/ no to yes), in sb having problem getting sleep, the odds of having problem sleeping GO UP 2.9
# interpretations!!!***:for every additional hour of sleep, the odds of having problem sleeping GO DOWN by a factor of 0.618
# ***the reason for GO DOWN***: because coefficient <1.  ???????
exp(coef(both2))



#range odds for model 1(Safisfaction)
min(HBAT_4_clean$Satisfaction)
max(HBAT_4_clean$Satisfaction)

IMinSat <- data.frame(Satisfaction=4.7)
IMaxSat <- data.frame(Satisfaction=9.9)
OddsMinSat <- exp(predict(both2, IMinSat))
OddsMinSat
OddsMaxSat <- exp(predict(both2, IMaxSat))
OddsMaxSat
OddsMinSat/OddsMaxSat #the range odds ratio for PurchaseLevel
# the direction matter! 


#Binary Log---- 
LogMod2 <- glm(
  StratAlliance~Satisfaction, 
  data=HBAT_4_clean, family="binomial")
summary(LogMod2)

#
#Test overall model----
anova(LogMod2, test="Chisq")
lrtest(LogMod2)
#Test Coefficient
wald.test(b=coef(LogMod2), Sigma=vcov(LogMod2), Terms=1)
wald.test(b=coef(LogMod2), Sigma=vcov(LogMod2), Terms=2)
#
##Odds of StratAlliance ----
#ln(Odds)
coef(LogMod2)
#Odds sleeping compared to non-prob sleeping
exp(coef(LogMod2))
#Odds no-prob sleeping compared to prob sleeping
1/exp(coef(LogMod2))


#
#Estimated Probability of StratAlliance
HBAT_4_clean$PredAlliance <- predict(LogMod2, type="response")
#View(HBAT_4_clean)
HBAT_4_clean$PredProb <- 0
HBAT_4_clean$PredProb[HBAT_4_clean$PredAlliance >= .5] <- 1
#View(HBAT_4_clean)


#confusion matrix
xtab <- table(HBAT_4_clean$StratAlliance,HBAT_4_clean$PredProb)
xtab
# percnt improvement
#how many wrong with no model
wrongNM <- min(rowSums(xtab))
#how many wrong with model
wrongWM <- sum(xtab)-sum(diag(xtab))
#percent improvement in error rate
(wrongNM-wrongWM)/wrongNM

#kappa
Alliance_kappa <- cohen.kappa(xtab)
Alliance_kappa$kappa

#ROC 
roc <- roc(HBAT_4_clean$StratAlliance,HBAT_4_clean$Satisfaction, direction=">") #creates an object with all sorts of diagnostics including sensitivities and specificities
plot(roc)

#-----------------------------------
#----------------------------------
#attempt 2/MODEL 2
all3 <- glm(StratAlliance ~ PurchaseLevel + 
              Customer_lessthan1yr + Customer_btwn_1_5yr +Customer_Over5yr + Size_Small+Size_Large, 
            data = HBAT_4_clean, family="binomial")
summary(all3)

#perform mixed stepwise regression
both3<- step(intercept_only2, direction='both', scope=formula(all3), trace=0)

#view results of mixed stepwise regression
both3$anova
summary(both3)

#View Model 2
both3$coefficients
exp(coef(both3))
# CAN'T compare the impact of Size & Satisfaction on sleep problem, 
# CAN'T compare the unit odds ratios to determine the relative impact of the independent variables
# because they are in different scales,solution: RANGE ODDS RATIOS

#range odds for model 1(Safisfaction)
min(HBAT_4_clean$PurchaseLevel)
max(HBAT_4_clean$PurchaseLevel)

IMinSat <- data.frame(PurchaseLevel=37.1,Customer_lessthan1yr=1,Size_Small=1,Customer_btwn_1_5yr=0)
IMaxSat <- data.frame(PurchaseLevel=77.1,Customer_lessthan1yr=1,Size_Small=1,Customer_btwn_1_5yr=0)
OddsMinSat <- exp(predict(both2, IMinSat))
OddsMinSat
OddsMaxSat <- exp(predict(both2, IMaxSat))
OddsMaxSat
OddsMinSat/OddsMaxSat #the range odds ratio for PurchaseLevel
# the direction matter! 


#Binary Log---- 
LogMod3 <- glm(
  StratAlliance~PurchaseLevel+Customer_lessthan1yr+Size_Small+Customer_btwn_1_5yr, 
  data=HBAT_4_clean, family="binomial")
summary(LogMod3)

#
#Test overall model----
anova(LogMod3, test="Chisq")
lrtest(LogMod3)
#Test Coefficient
wald.test(b=coef(LogMod3), Sigma=vcov(LogMod3), Terms=1)
wald.test(b=coef(LogMod3), Sigma=vcov(LogMod3), Terms=2)
#
##Odds of StratAlliance ----
#ln(Odds)
coef(LogMod3)
#Odds sleeping compared to non-prob sleeping
exp(coef(LogMod3))
#Odds no-prob sleeping compared to prob sleeping
1/exp(coef(LogMod3))


#
#Estimated Probability of StratAlliance
HBAT_4_clean$PredAlliance <- predict(LogMod3, type="response")
#View(HBAT_4_clean)
HBAT_4_clean$PredProb <- 0
HBAT_4_clean$PredProb[HBAT_4_clean$PredAlliance >= .5] <- 1
#View(HBAT_4_clean)


#confusion matrix
xtab <- table(HBAT_4_clean$StratAlliance,HBAT_4_clean$PredProb)
xtab
# percnt improvement
#how many wrong with no model
wrongNM <- min(rowSums(xtab))
#how many wrong with model
wrongWM <- sum(xtab)-sum(diag(xtab))
#percent improvement in error rate
(wrongNM-wrongWM)/wrongNM

#kappa
Alliance_kappa <- cohen.kappa(xtab)
Alliance_kappa$kappa

#ROC 
roc <- roc(HBAT_4_clean$StratAlliance,HBAT_4_clean$c(PurchaseLevel), direction=">") #creates an object with all sorts of diagnostics including sensitivities and specificities
plot(roc)

