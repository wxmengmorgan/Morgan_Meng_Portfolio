# 
# 5.	Build a model to predict Segment by PQuality—Delivery. Do this using 2 different analytic approaches. 
# Compare the two approaches and describe which one you prefer in this case.

# load packages
library(ggplotgui)
library(ggplot2)
library(irr)
library(MASS)
library(MVN)
library(mvnormtest)
library(nnet)
library(psych)
library(readxl)
library(shiny)

HBAT<- readRDS(file.choose())

# get data
HBAT_Q5<- subset.data.frame(
  HBAT, select=c("Segment","PQuality", "Etail","TechSup","CompResolve","Advertising", "Products", 
                 "Sales","Pricing","Warranty","NewProd","Billing","PriceFlex","Delivery"))
names(HBAT_Q5)

# examine data (missing values, outliers, multicollinearity)
cor(HBAT_Q5[ ,-1])
ggplot_shiny(HBAT_Q5) #CHECKING OUTLIERS 
mvnObj <- mvn(
  data=HBAT_Q5[ ,-1],
  mvnTest="hz",
  univariateTest = "AD",
  multivariatePlot = "qq",
  multivariateOutlierMethod = "adj",
  showOutliers = TRUE,
  showNewData = TRUE)

# Calculate distances (using Mahalanobis distance as an example)
distances2 <- mahalanobis(HBAT_Q5[, 2:14], colMeans(HBAT_Q5[, 2:14]), cov(HBAT_Q5[, 2:14]))

# Define threshold (e.g., based on quantiles)
threshold2 <- quantile(distances2, 0.95)

# Identify observations exceeding the threshold
outlier_indices2 <- which(distances2 > threshold2)

# Remove outliers
HBAT_Q5_clean <- HBAT_Q5[-outlier_indices2, ]

# 1st Check for multifollinearity 
cor(HBAT_Q5_clean[ ,-1])
# in this step, looking for correlations that are problematically high, abosolute value>= 0.7!!!


# Preparing Data 
# first set up reference level
# DV needs to be made an unordered factor
HBAT_Q5_clean$Segment <- as.factor(HBAT_Q5_clean$Segment)
# then set reference level in new variable
HBAT_Q5_clean$Segment2 <- relevel(HBAT_Q5_clean$Segment, ref = "A")

LogMod3 <- multinom(
  Segment2 ~ PQuality+Etail + TechSup+ CompResolve + Advertising+ Products + Sales + 
    Pricing + Warranty + NewProd + Billing + PriceFlex + Delivery,  
  data=HBAT_Q5_clean)
#  Test the goodness of fit
chisq.test(HBAT_Q5_clean$Segment2,predict(LogMod3))

# logistic Regression results
summary(LogMod3)

# significance of parameters
TestPQuality <- multinom(
  Segment2 ~ Etail+TechSup+ CompResolve + Advertising+ Products + Sales + 
    Pricing + Warranty + NewProd + Billing + PriceFlex + Delivery, 
  data=HBAT_Q5_clean)
anova(LogMod3, TestPQuality)

#Etail sign
TestEtail <- multinom(
  Segment2 ~ PQuality+TechSup+ CompResolve + Advertising+ Products + Sales + 
    Pricing + Warranty + NewProd + Billing + PriceFlex + Delivery, 
  data=HBAT_Q5_clean)
anova(LogMod3, TestEtail)

TestTechSup <- multinom(
  Segment2 ~ PQuality+Etail + CompResolve + Advertising+ Products + Sales + 
    Pricing + Warranty + NewProd + Billing + PriceFlex + Delivery, 
  data=HBAT_Q5_clean)
anova(LogMod3, TestTechSup)

TestCompResolve <- multinom(
  Segment2 ~ PQuality+Etail + TechSup+ Advertising+ Products + Sales + 
    Pricing + Warranty + NewProd + Billing + PriceFlex + Delivery, 
  data=HBAT_Q5_clean)
anova(LogMod3, TestCompResolve)

TestAdvertising <- multinom(
  Segment2 ~ PQuality+Etail + TechSup+ CompResolve + Products + Sales + 
    Pricing + Warranty + NewProd + Billing + PriceFlex + Delivery, 
  data=HBAT_Q5_clean)
anova(LogMod3, TestAdvertising)

#product sign
TestProducts <- multinom(
  Segment2 ~ PQuality+Etail + TechSup+ CompResolve + Advertising+  Sales + 
    Pricing + Warranty + NewProd + Billing + PriceFlex + Delivery, 
  data=HBAT_Q5_clean)
anova(LogMod3, TestProducts)

#Sales sign
TestSales <- multinom(
  Segment2 ~ PQuality+Etail + TechSup+ CompResolve + Advertising+ Products + 
    Pricing + Warranty + NewProd + Billing + PriceFlex + Delivery, 
  data=HBAT_Q5_clean)
anova(LogMod3, TestSales)

TestPricing <- multinom(
  Segment2 ~ PQuality+Etail + TechSup+ CompResolve + Advertising+ Products + Sales + 
     Warranty + NewProd + Billing + PriceFlex + Delivery, 
  data=HBAT_Q5_clean)
anova(LogMod3, TestPricing)

TestWarranty <- multinom(
  Segment2 ~ PQuality+Etail + TechSup+ CompResolve + Advertising+ Products + Sales + 
    Pricing  + NewProd + Billing + PriceFlex + Delivery, 
  data=HBAT_Q5_clean)
anova(LogMod3, TestWarranty)

#NewProd sign
TestNewProd <- multinom(
  Segment2 ~ PQuality+Etail + TechSup+ CompResolve + Advertising+ Products + Sales + 
    Pricing + Warranty  + Billing + PriceFlex + Delivery, 
  data=HBAT_Q5_clean)
anova(LogMod3, TestNewProd)

TestBilling <- multinom(
  Segment2 ~ PQuality+Etail + TechSup+ CompResolve + Advertising+ Products + Sales + 
    Pricing + Warranty + NewProd  + PriceFlex + Delivery, 
  data=HBAT_Q5_clean)
anova(LogMod3, TestBilling)

#PriceFlex Sign
TestPriceFlex <- multinom(
  Segment2 ~ PQuality+Etail + TechSup+ CompResolve + Advertising+ Products + Sales + 
    Pricing + Warranty + NewProd + Billing + Delivery, 
  data=HBAT_Q5_clean)
anova(LogMod3, TestPriceFlex)

TestDelivery <- multinom(
  Segment2 ~ PQuality+Etail + TechSup+ CompResolve + Advertising+ Products + Sales + 
    Pricing + Warranty + NewProd + Billing + PriceFlex, 
  data=HBAT_Q5_clean)
anova(LogMod3, TestDelivery)

#NewProd sign
#Etail sign
#product sign
#Sales sign
#PriceFlex Sign

# unit odds ratios
exp(coef(LogMod3))

#----------------------------
# # # # # # # # # # # 
# MIXED STEP-WISE REGRESSION
# define intercept-only model
intercept_only3 <- multinom(Segment2 ~ 1, 
                           data=HBAT_Q5_clean)

# define model with all predictors
all3 <- multinom(Segment2 ~  PQuality+Etail + TechSup+ CompResolve + Advertising+ Products + Sales + 
                  Pricing + Warranty + NewProd + Billing + PriceFlex + Delivery, 
                data=HBAT_Q5_clean)
summary(all3)

# perform mixed stepwise regression
both3 <- step(intercept_only3, direction='both', scope=formula(all3), trace=0)

# view results of mixed stepwise regression
both3$anova
summary(both3)


# # Odds of Buying Different Car Nationalities----
# ln(Odds)
coef(both3)
# Odds each National origin car compared to buying a Segment A
exp(coef(both3))

# Estimated Probability of buying each national origin car vs buying German
HBAT_Q5_clean <- cbind(HBAT_Q5_clean,both3$fitted.values)
View(HBAT_Q5_clean)

HBAT_Q5_clean$PredSegment <- predict(both3)
View(HBAT_Q5_clean)

# input for estimate
I4 <- data.frame(NewProd=4.3, Warranty=5)

# probs for estimate
probI4 <- predict(both3, I4, "probs")
probI4

# odds for estimate
oddsI4  <-  probI4/(1-probI4)
oddsI4

# confusion matrix
xtab2 <- table(HBAT_Q5_clean$Segment2,HBAT_Q5_clean$PredSegment)
xtab2
bg2 <- table(HBAT_Q5_clean$Segment2)
bg2
#  percnt improvement
# how many wrong with no model
wrongNM2 <- sum(xtab2)-max(rowSums(xtab2)) 
# how many wrong with model
wrongWM2 <- sum(xtab2)-sum(diag(xtab2))
# percent improvement in error rate
(wrongNM2-wrongWM2)/wrongNM2

# kappa
CPkML2 <- cohen.kappa(xtab2)
CPkML2$kappa


#NewProd sign
#Etail sign
#product sign
#Sales sign
#PriceFlex Sign
#
# range odds
min(HBAT_Q5_clean$NewProd)
max(HBAT_Q5_clean$NewProd)

minFI <- data.frame(NewProd=1.2, Warranty=4.5)
maxFI <- data.frame(NewProd= 3.9, Warranty=4.5)
ProbMinFI <- predict(both3, minFI, "probs")
OddsMinFI <- ProbMinFI/(1-ProbMinFI)
OddsMinFI
ProbMaxFI <- predict(both3, maxFI, "probs")
OddsMaxFI <- ProbMaxFI/(1-ProbMaxFI)
OddsMaxFI
OddsMaxFI/OddsMinFI # the range odds ratio for TechSup


min(HBAT_Q5_clean$Warranty)
max(HBAT_Q5_clean$Warranty)

minLC <- data.frame(NewProd= 5.5, Warranty=3.9)
maxLC <- data.frame(NewProd=5.5, Warranty=8.4)
ProbMinLC <- predict(both3, minLC, "probs")
OddsMinLC <- ProbMinLC/(1-ProbMinLC)
OddsMinLC
ProbMaxLC <- predict(both3, maxLC, "probs")
OddsMaxLC <- ProbMaxLC/(1-ProbMaxLC)
OddsMaxLC
OddsMaxLC/OddsMinLC # the range odds ratio for LibConserv

# Repeat for any additional IVs

#--------------------------------------------
# Discriminant Analysis

#Scatterplots for items

biplots <- as.data.frame(cbind(
  HBAT_Q5_clean[,2:14]))
pairs(biplots, upper.panel=NULL)

fit <- lda(Segment2 ~ PQuality+Etail + TechSup+ CompResolve + Advertising+ Products + Sales + 
             Pricing + Warranty + NewProd + Billing + PriceFlex + Delivery, 
           data=HBAT_Q5_clean)
fit # print the summary statistics of your discriminant analysis

# Check which Discriminant Functions are Significant. 
# Remember that there are 1 fewer functions than there are groups.
ldaPred <- predict(fit, HBAT_Q5_clean)
ld <- ldaPred$x
anova(lm(ld[,1] ~ HBAT_Q5_clean$Segment2))
anova(lm(ld[,2] ~ HBAT_Q5_clean$Segment2))
anova(lm(ld[,3] ~ HBAT_Q5_clean$Segment2))

# Check Disciminant Model Fit
pred.seg <- predict(fit)$class
tseg <- table(HBAT_Q5_clean$Segment2, pred.seg)
# how many wrong with no model
wrongNM3 <- sum(tseg)-max(rowSums(tseg)) 
# how many wrong with model
wrongWM3 <- sum(tseg)-sum(diag(tseg))
# percent improvement in error rate
(wrongNM3-wrongWM3)/wrongNM3

# kappa
CPkML3 <- cohen.kappa(tseg)
CPkML3$kappa

tseg # print table
sum(diag(tseg))/nrow(HBAT_Q5_clean) # print percent correct

# Run Classification Using Discriminant Function
pred.class <- predict(fit, HBAT_Q5_clean)$class
tclass <- table(pred.class)
tclass # print table

