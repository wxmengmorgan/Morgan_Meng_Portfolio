#assumption checking

library(tidyverse)
library(magrittr) # for pipe operator %>%
library(car) # for diagnostics and checking assumptions
library(broom) # for tidy model outputs

# load packages
library(DataExplorer)
library(dplyr)
library(epiDisplay)
library(ggplot2)
library(ggplotgui)
library(mice)
library(psych)
library(emmeans)
library(multcomp) 
library(multcompView) 

library(carData)
library(caret)
library(fastDummies)
library(leaps)
library(lm.beta)
library(MVN)
library(ppcor)

library(Stat2Data)
library(Rmisc)

#LOAD file
HBAT<- readRDS(file.choose())

# Chekcing Missing Data if there is any

#plot missingness in data
missing <- plot_missing(HBAT)

#see the same info in table form
missing$data

# get IDs for participants with missing data by creating a new dataframe with just those respondents and listing their IDs
missing$ID. #ends here

HBAT_1 <- subset.data.frame(
  HBAT, select=c("PurchaseLevel","Segment"))
names(HBAT_1)
#
# For Q1: Does Purchase Level vary by Segment?

# PurchaseLevel is a continuous variable and Segment is categorical
# Check Assumptions----
# Histogram by Groups
# Create separate data for each group
Seg_A <- subset(HBAT_1, 
                Segment=="A")
Seg_B <- subset(HBAT_1, 
                Segment=="B")
Seg_C <- subset(HBAT_1, 
                Segment=="C")
Seg_D <- subset(HBAT_1, 
                Segment=="D")

# Check new data frames compare counts below to object in Environment tab
table(HBAT_1$Segment)
#
# Create graphs
ggplot(data=Seg_A, 
       aes(x=PurchaseLevel))+ 
  geom_histogram(position="identity", 
                 binwidth=3, col="white")+ 
  theme_classic()+labs(title="Segment A")
ggplot(data=Seg_B, 
       aes(x=PurchaseLevel))+ 
  geom_histogram(position="identity", 
                 binwidth=3, col="white")+ 
  theme_classic()+labs(title="Seg_B")
ggplot(data=Seg_C, 
       aes(x=PurchaseLevel))+ 
  geom_histogram(position="identity", 
                 binwidth=3, col="white")+ 
  theme_classic()+labs(title="Seg_C")
ggplot(data=Seg_D, 
       aes(x=PurchaseLevel))+ 
  geom_histogram(position="identity", 
                 binwidth=3, col="white")+ 
  theme_classic()+labs(title="Seg_D")

# Alternatve view
# Boxplot by Groups
ggplot(data=HBAT_1, 
       aes(x=Segment, y=PurchaseLevel,
           color=Segment)) +
  geom_boxplot(notch = FALSE, width=.3)+
  scale_color_brewer(palette="Set1") +
  labs(title="PurchaseLevel Boxplot", subtitle="by Segments",
       x="Segment", y="PurchaseLevel (M)") + 
  theme_classic() + 
  theme(axis.title = element_text(size = 12),
        plot.title=element_text(hjust=.5),
        plot.subtitle=element_text(hjust=.5),
        legend.position = "none")

# Any transformations to the data?
# Levene's Test. ANOVA is robust to violations when the sample size is large
leveneTest(PurchaseLevel~Segment, 
           data=HBAT_1)

aov_result1 <- aov(PurchaseLevel ~ Segment, data = HBAT_1)
summary(aov_result1) # Is the ANOVA significant? What does that mean?

aov_summary1 <- aov_result1 %>%
  Anova(type = "III") %>%
  summary()

marginal <- aov_result1 %>%
  emmeans(~ Segment)

pairs <- marginal %>%
  pairs(adjust = "tukey")
pairs  # Even with a small number of groups, this format is hard to take in all at once

cld <- marginal %>%
  cld(alpha = .05, Letters = letters)
cld  # compact letters give a more concise summary of differences

aov_graph1 <- ggplot(data = cld, aes(x = Segment, y = emmean, fill = Segment)) +
  geom_col(position = "dodge") +
  geom_errorbar(aes(ymin = lower.CL, ymax = upper.CL), position = position_dodge(width = 0.9), width = 0.2) +
  geom_text(data = cld, aes(x = Segment, y = emmean + emmean * 0.1, label = .group), position = position_dodge(width = 0.9)) +
  labs(x = "Segment", y = "PurchaseLevel", fill = "Segment") +
  theme_minimal()
aov_graph1

# Create a table of the results
# Descriptives by Group
DescByGrp <- HBAT_1 %>% 
  group_by(Segment) %>%
  dplyr::summarize(number=n(),
            mean=round(mean(PurchaseLevel), 3),
            sd=round(sd(PurchaseLevel), 3),
            se=round(sd/sqrt(number), 3))

View(DescByGrp) 

