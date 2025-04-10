# load packages
library(cluster)
library(factoextra)
library(gridExtra)
library(NbClust)
library(tidyverse)

#LOAD file
HBAT<- readRDS(file.choose())

# Get data
HBAT_Cluster <- subset.data.frame(
  HBAT, select=c("PQuality", "Etail","TechSup","CompResolve","Advertising", "Products", 
                 "Sales","Pricing","Warranty","NewProd","Billing","PriceFlex","Delivery"))
names(HBAT_Cluster)

# subset to variables we'll use
df <- HBAT_Cluster[ ,c("PQuality", "Etail","TechSup","CompResolve","Advertising", "Products", 
                   "Sales","Pricing","Warranty","NewProd","Billing","PriceFlex","Delivery")] 

# scale each variable to have a mean of 0 and sd of 1
df <- scale(df)

# view first six rows of dataset
head(df)

set.seed(1234)

# Hierarchical 

# define linkage methods
# using this line to determine which method works better
m <- c( "average", "single", "complete", "ward")
names(m) <- c( "average", "single", "complete", "ward")

# function to compute agglomerative coefficient
#create a function to apply 4 linkage methods
ac <- function(x) {
  agnes(df, method = x)$ac
}

# calculate agglomerative coefficient for each clustering linkage method
sapply(m, ac)
# from the result, the bigger the value the better the method 

# perform hierarchical clustering using Ward's minimum variance
clust <- agnes(df, method = "ward")
# data.frame(clust[c(2,4)])

#the following codes show us exactly steps the clusters were joint
# aglomeration schedule
# hc3 <- hclust(dist(df))
# data.frame(hc3[2:1])

# produce dendrogram
fviz_dend(clust)
#in the graph, find where the gap becomes noticible smaller.
#in this case, 4 is the optimal number

# stats for number of clusters
res.nbclust <- NbClust(df, distance = "euclidean",
                       min.nc = 2, max.nc = 10, 
                       method = "ward.D", index ="all")
#this line summarizes how many clusters are more likely to be good number of clusters.
table(res.nbclust$Best.nc[1,]) # shows outcome in table form

# calculate gap statistic for each number of clusters (up to 10 clusters)
 gap_stat <- clusGap(df, FUN = hcut, nstart = 25, K.max = 10, B = 100)

#produce plot of clusters vs. different fit statistics
fviz_gap_stat(gap_stat)
fviz_nbclust(df, FUN = hcut, method = "wss")
fviz_nbclust(df, FUN = hcut, method = "silhouette")

#compute distance matrix
d <- dist(df, method = "euclidean")

#perform hierarchical clustering using optimal method
final_clust <- hclust(d, method = "ward.D2" )

#cut the dendrogram into clusters
#change K's value to change the cluster numbers#
groups <- cutree(final_clust, k=3)

#find number of observations in each cluster
#each cluster should be less than 10% of sample
table(groups)

#append cluster labels to original data
HBAT_Cluster <- cbind(HBAT_Cluster, Hcluster = groups)

#display first six rows of final data
head(HBAT_Cluster)

#find mean values for each cluster
aggregate(HBAT_Cluster, by=list(cluster=HBAT_Cluster$Hcluster), mean)

#analying the statistical significance between groups, ANOVA,Logistic regression and discriminat regression

# Visualize the result in a scatter plot
fviz_cluster(list(data = df, cluster = groups))

# K-Means

# plots to compare
k2 <- kmeans(df, centers = 2, nstart = 25)
k3 <- kmeans(df, centers = 3, nstart = 25)
k4 <- kmeans(df, centers = 4, nstart = 25)
k5 <- kmeans(df, centers = 5, nstart = 25)
k6 <- kmeans(df, centers = 6, nstart = 25)
k7 <- kmeans(df, centers = 7, nstart = 25)
k8 <- kmeans(df, centers = 8, nstart = 25)

p1 <- fviz_cluster(k2, geom = "point", data = df) + ggtitle("k = 2")
p2 <- fviz_cluster(k3, geom = "point",  data = df) + ggtitle("k = 3")
p3 <- fviz_cluster(k4, geom = "point",  data = df) + ggtitle("k = 4")
p4 <- fviz_cluster(k5, geom = "point",  data = df) + ggtitle("k = 5")
p5 <- fviz_cluster(k6,geom = "point", data =df) + ggtitle("k =6")
p6 <- fviz_cluster(k7,geom = "point", data =df) + ggtitle("k =7")
p7 <- fviz_cluster(k8,geom = "point", data =df) + ggtitle("k =8")

grid.arrange(p1, p2, p3, p4, p5, p6, p7, nrow = 3)

# Compute k-means clustering. Set k = to the number of clusters you want it to find.
# generally will use the number we settled on from the Hierarchical model.
final <- kmeans(df, 3, nstart = 25)
print(final)

fviz_cluster(final, data = df)

meansBycluster <- HBAT_Cluster %>%
  dbplyr::group_by(Cluster = final$cluster) %>%
  group_by(Cluster) %>%
  summarise_all("mean")

meansBycluster

HBAT_Cluster<-HBAT_Cluster[,-14]

HBAT_Cluster<- cbind(HBAT_Cluster, Kcluster = final$cluster)

#Anova
anova_model <- aov(cbind(PQuality, Etail,TechSup,CompResolve,Advertising, Products, 
                         Sales,Pricing,Warranty,NewProd,Billing,PriceFlex,Delivery) ~ Kcluster, data = HBAT_Cluster)

# View ANOVA results
summary(anova_model)



# multinominal Logistic Regression

HBAT_Cluster$Kcluster <- as.factor(HBAT_Cluster$Kcluster)
# then set reference level in new variable
HBAT_Cluster$Kcluster2 <- relevel(HBAT_Cluster$Kcluster, ref = 1)

names(HBAT_Cluster)
multinom_model <- multinom(Kcluster2 ~ PQuality + Etail+ CompResolve+ Advertising+ Products+ 
                           Sales+Billing+PriceFlex+Delivery, data = HBAT_Cluster)

# View multinomial logistic regression results
summary(multinom_model)


chisq.test(HBAT_Cluster$Hcluster,predict(multinom_model))

# MIXED STEP-WISE REGRESSION
# define intercept-only model
intercept_only4 <- multinom(Kcluster2~ 1, 
                           data=HBAT_Cluster)
# perform mixed stepwise regression
both4 <- step(intercept_only4, direction='both', scope=formula(multinom_model), trace=0)

# view results of mixed stepwise regression
both4$anova
summary(both4)
# # Odds of different clusters----
# ln(Odds)
coef(both4)
# Odds to get into other cluster rather than "1"
exp(coef(both4))



HBAT_Cluster$predict <- predict(both4)
View(HBAT_Cluster)

# input for estimate
I1 <- data.frame(Age=56, Income=15, Spend_Score=13)

# probs for estimate
probI1 <- predict(both, I1, "probs")
probI1

# odds for estimate
oddsI1  <-  probI1/(1-probI1)
oddsI1

# confusion matrix
xtab <- table(HBAT_Cluster$Kcluster2,HBAT_Cluster$predict)
xtab

#  percnt improvement
# how many wrong with no model
wrongNM <- sum(xtab)-max(rowSums(xtab)) 
# how many wrong with model
wrongWM <- sum(xtab)-sum(diag(xtab))
# percent improvement in error rate
(wrongNM-wrongWM)/wrongNM

# kappa
CPkML <- cohen.kappa(xtab)
CPkML$kappa