# 2.	Build a model to predict Satisfaction by the variables PQuality—Delivery. 
# You should build as parsimonious model as possible, that, at the same time, is highly predictive of the DV.


#LOAD file
HBAT<- readRDS(file.choose())

#Subset for regression model
HBAT_2<- subset.data.frame(
  HBAT, select=c("Satisfaction","PQuality", "Etail","TechSup","CompResolve","Advertising", "Products", "Sales","Pricing","Warranty","NewProd","Billing","PriceFlex","Delivery"))
names(HBAT_2)

pairs(HBAT_2, upper.panel=NULL)

#ggplotgui for easy histograms and scatterplots
ggplot_shiny(HBAT_2) #histograms of the DV and IVs and scatterplots of DV against each IV

#Check for multivariate outliers
mvnObj <- mvn(
  data= HBAT_2[ ,2:14], #THESE NUMBERS ARE THE COLUMNS FOR THE IVs IN HBAT_2, ADJUST AS NEEDED
  mvnTest="hz",
  univariateTest = "AD",
  multivariatePlot = "qq",
  multivariateOutlierMethod = "adj",
  showOutliers = TRUE,
  showNewData = TRUE)

# Calculate distances (using Mahalanobis distance)
distances <- mahalanobis(HBAT_2[, 2:14], colMeans(HBAT_2[, 2:14]), cov(HBAT_2[, 2:14]))

# Define threshold (e.g., based on quantiles)
threshold <- quantile(distances, 0.95)

# Identify observations exceeding the threshold
outlier_indices <- which(distances > threshold)

# Remove outliers
HBAT_2_clean<- HBAT_2[-outlier_indices, ]

#Check for multivariate outliers
mvnObj2 <- mvn(
  data= HBAT_2_clean[ ,2:14], #THESE NUMBERS ARE THE COLUMNS FOR THE IVs IN HBAT_2, ADJUST AS NEEDED
  mvnTest="hz",
  univariateTest = "AD",
  multivariatePlot = "qq",
  multivariateOutlierMethod = "adj",
  showOutliers = TRUE,
  showNewData = TRUE)

# 1st Check for multifollinearity 
cor(HBAT_2_clean)
cor(HBAT_2_clean[ ,-1])
# in this step, looking for correlations that are problematically high, abosolute value>= 0.7!!!

#MULTIPLE REGRESSION ALL IVs
# 1st Attempt
regAll <- lm(Satisfaction ~ PQuality+ Etail + TechSup+ CompResolve + Advertising+ Products + Sales 
             + Pricing + Warranty + NewProd + Billing + PriceFlex + Delivery, HBAT_2_clean)
summary(regAll)
vif(regAll) #asking for variance inflation factors
#for Satisfaction vs. partial satisfaction, it should be positie number, never negative number.
plot(regAll)

#MULTIPLE REGRESSION ALL IVs
# 2st Attempt:-Products,PriceFlex, Delivery 
regAll2 <- lm(Satisfaction ~ PQuality+Etail + TechSup+ CompResolve + Advertising + Sales + Pricing + Warranty + NewProd + Billing, HBAT_2_clean)
summary(regAll2)
vif(regAll2) #asking for variance inflation factors
#for Satisfaction vs. partial satisfaction, it should be positie number, never negative number.
plot(regAll2)

#MULTIPLE REGRESSION ALL IVs
# 3st Attempt -TechSup,Warranty
regAll3<- lm(Satisfaction ~ PQuality+Etail + CompResolve + Advertising + Sales + Pricing + NewProd + Billing, HBAT_2_clean)
summary(regAll3)
vif(regAll3) #asking for variance inflation factors
#for Satisfaction vs. partial satisfaction, it should be positie number, never negative number.
plot(regAll3)

#MULTIPLE REGRESSION ALL IVs
# 4st Attempt -Sales
regAll4<- lm(Satisfaction ~ PQuality+Etail + CompResolve + Advertising  + Pricing + NewProd + Billing, HBAT_2_clean)
summary(regAll4)
vif(regAll4) #asking for variance inflation factors
#for Satisfaction vs. partial satisfaction, it should be positie number, never negative number.
plot(regAll4)

#MULTIPLE REGRESSION ALL IVs
# 5st Attempt - +Sales -Pricing,Billing
regAll5<- lm(Satisfaction ~ PQuality+Etail + CompResolve + Advertising  + Sales + NewProd, HBAT_2_clean)
summary(regAll5)
vif(regAll5) #asking for variance inflation factors
#for Satisfaction vs. partial satisfaction, it should be positie number, never negative number.
plot(regAll5)

#MULTIPLE REGRESSION ALL IVs
# 6st Attempt - +Sales -Pricing,Billing
regAll6<- lm(Satisfaction ~ PQuality+Etail + CompResolve   + Sales + NewProd, HBAT_2_clean)
summary(regAll5)
vif(regAll6) #asking for variance inflation factors
#for Satisfaction vs. partial satisfaction, it should be positie number, never negative number.
plot(regAll6)

#MIXED STEP-WISE REGRESSION
#define intercept-only model
intercept_only1 <- lm(Satisfaction ~ 1, data = HBAT_2_clean)

#define model with all predictors
all1 <- lm(Satisfaction ~ PQuality+ Etail + +TechSup+ CompResolve + Advertising+ Products + Sales + 
            Pricing + Warranty + NewProd + Billing + PriceFlex + Delivery, 
          HBAT_2_clean)

#perform mixed stepwise regression
both1 <- step(intercept_only1, direction='both', scope=formula(all1), trace=0)

#view results of mixed stepwise regression
both1$anova

#view final model
both1$coefficients

mixed1 <- lm(Satisfaction ~ Products+Sales+PQuality+PriceFlex+Etail+Pricing+CompResolve+NewProd , 
            HBAT_2_clean)
summary(mixed1)
vif(mixed1)

#BEST SUBSETS REGRESSION
Best_HBATreg <- regsubsets(Satisfaction ~ PQuality + Etail + +TechSup+ CompResolve + Advertising+ Products + Sales + 
                             Pricing + Warranty + NewProd + Billing + PriceFlex + Delivery, 
                           data=HBAT_2_clean,
                           nbest = 1, # 1 best model for each number of predictors
                           nvmax = NULL, # NULL for no limit on number of variables
                           force.in = NULL, force.out = NULL,
                           method = "exhaustive")
summary(Best_HBATreg)
summary_best_subset <- summary(Best_HBATreg)
as.data.frame(summary_best_subset$outmat)

summary_best_subset$adjr2 #giving adjusted R-square for each model. looking for PLATEAU!!!
summary_best_subset$cp # Giving Mellow Cp. looking for BOTTOM LOW!!
which.max(summary_best_subset$adjr2)
which.min(summary_best_subset$cp) 
# choose the model balancing the desire for the largest adj r-sq, the lowest CP, and the fewest IVs (parsimony)
summary_best_subset$which[6,]

finalHBATreg <- lm(Satisfaction ~ PQuality+ Etail  + Sales +Products + PriceFlex, HBAT_2_clean)
summary(finalHBATreg)
lm.beta(finalHBATreg) #dummy variable and other variables are NOT in the same scale, so we cannot compare intercept directly.
#therefore, standardized coefficients are necessary!

vif(finalHBATreg)
# QUESTION: dummy variables if don't get into the model


