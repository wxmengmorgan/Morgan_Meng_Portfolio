# 3.	Does Recommend vary by Customer and Region?

#LOAD file
HBAT<- readRDS(file.choose())

HBAT_3<-subset.data.frame(HBAT, select=c("Recommend","Customer","Region"))


#chi_square_result <- chisq.test(HBAT_3$Recommend, HBAT_3$Customer)
#chi_square_result
# Or ANOVA if Customer and Region are continuous variables
#anova_result2 <- aov(Recommend ~ Customer + Region, data = HBAT_3)
#summary(anova_result2)

#Check Assumptions----
#Create histograms by cell 
#Create Domestic-lessthan1yr Data Frame 1
Domesticlessthan1yr <- subset(HBAT_3, 
                              Region=="Domestic" & 
                                Customer=="lessthan1yr")
#Produce Recommend histogram for Domestic-lessthan1yr
ggplot(data=Domesticlessthan1yr, 
       aes(x=Recommend))+ 
  geom_histogram(position="identity", 
                 binwidth=0.5, col="white")+ 
  theme_classic()+
  labs(title="Domestic-lessthan1yr")

#
#Create Domestic-btwn_1_5yr Data Frame 2
Domesticbtwn_1_5yr <- subset(HBAT_3, 
                             Region=="Domestic" & 
                               Customer=="btwn_1_5yr")
#Produce Recommend histogram for Domestic-btwn_1_5yr 
ggplot(data=Domesticbtwn_1_5yr, 
       aes(x=Recommend))+ 
  geom_histogram(position="identity", 
                 binwidth=0.3, col="white")+ 
  theme_classic()+
  labs(title="Domestic-btwn_1_5yr")

#
#Create Domestic-Over5yr Data Frame 3
DomesticOver5yr <- subset(HBAT_3, 
                          Region=="Domestic" & 
                            Customer=="Over5yr")
#Produce Recommend histogram for Domestic-Over5yr
ggplot(data=DomesticOver5yr, 
       aes(x=Recommend))+ 
  geom_histogram(position="identity", 
                 binwidth=0.5, col="white")+ 
  theme_classic()+
  labs(title="Domestic-Over5yr")
#
#Create Intl-lessthan1yr Data Frame 4
Intllessthan1yr <- subset(HBAT_3, 
                                Region=="International" & 
                                  Customer=="lessthan1yr")
#Produce Recommend histogram for International-lessthan1yr
ggplot(data=Intllessthan1yr, 
       aes(x=Recommend))+ 
  geom_histogram(position="identity", 
                 binwidth=0.5, col="white")+ 
  theme_classic()+
  labs(title="Intl-lessthan1yr")

#
#Create Intl-btwn_1_5yr Data Frame 5
Intlbtwn_1_5yr <- subset(HBAT_3, 
                               Region=="International" & 
                                 Customer=="btwn_1_5yr")
#Produce Recommend histogram for Intl-btwn_1_5yr 
ggplot(data=Intlbtwn_1_5yr, 
       aes(x=Recommend))+ 
  geom_histogram(position="identity", 
                 binwidth=0.5, col="white")+ 
  theme_classic()+
  labs(title="Intl--btwn_1_5yr")


#Create Intl--Over5yr Data Frame 6
IntlOver5yr <- subset(HBAT_3, 
                            Region=="International" & 
                              Customer=="Over5yr")
#Produce Recommend histogram for Intl--Over5yr
ggplot(data=IntlOver5yr, 
       aes(x=Recommend))+ 
  geom_histogram(position="identity", 
                 binwidth=0.5, col="white")+ 
  theme_classic()+
  labs(title="Intl-Over5yr")


#
#Boxplot by Cell
ggplot(data=HBAT_3, 
       aes(x=Region, y=Recommend,
           fill=Customer)) +
  geom_boxplot(notch = FALSE, width=.3)+
  scale_fill_brewer(palette="Set1") +
  labs(title="Recommends Boxplot", 
       subtitle="by Customer and Region",
       fill="Customer",
       x="Region", y="Recommends") + 
  theme_classic() + 
  theme(axis.title = element_text(size = 12),
        plot.title=element_text(hjust=.5),
        plot.subtitle=element_text(hjust=.5))

#
#Performing Factorial ANOVA----
#Add ID column
HBAT_3$ID <- seq.int(nrow(HBAT_3))
#View(HBAT_3)
#
FacAOV <- aov(data = HBAT_3, Recommend ~ Customer*Region)
summary(FacAOV)
TukeyHSD(FacAOV)

#follow-up contrasts
followups <- emmeans(FacAOV, ~ Customer:Region, adjust = "sidak")
followups
pairs(followups, adjust = "tukey")
FacAOV_cld <- cld(followups, alpha = .05, Letters = letters)
FacAOV_cld

FacAOV_graph <- ggplot(data = FacAOV_cld, aes(x = Region, y = emmean, fill = Customer)) +
  geom_col(position = position_dodge(width = 0.9)) +
  geom_errorbar(aes(ymin = lower.CL, ymax = upper.CL), position = position_dodge(width = 0.9), width = 0.2) +
  
  # Add labels with letters above the error bars
  geom_text(aes(label = .group, y = upper.CL + 0.1), position = position_dodge(width = 0.9), 
            vjust = -0.5, size = 4.5) + 
  
  # Set axis labels and theme
  labs(x = "Region", y = "Recommend Score", fill = "Career Group") +
  theme_minimal()

# Display the plot
FacAOV_graph


#
#Presenting results----
ciPercent <- 95
DescByCell <- HBAT_3 %>% group_by(Customer, Region) %>% 
  dplyr::summarize(N=n(),Mean=mean(Recommend),
            sd=sd(Recommend),se=sd/sqrt(N), 
            ci=se*(qt((ciPercent/100)/2+.5, N-1)),
            LL=round(Mean-ci, 3), 
            UL=round(Mean+ci, 3))
#View(DescByCell)
#
#Plots: Bar Chart by Cell
ggplot(data=DescByCell, 
       aes(x=Region, y=Mean,
           fill=Customer)) +
  geom_bar(stat="identity", position="dodge")+
  geom_errorbar(aes(ymin=Mean-ci, ymax=Mean+ci),
                width=.1, position=position_dodge(width=.9))+
  scale_fill_brewer(palette="Set1") +
  labs(title="Recommends", 
       subtitle="by Customer and Region",
       fill="Customer",
       x="Region", y="Recommends (M)") + 
  theme_classic() +
  theme(axis.title = element_text(size = 12),
        plot.title=element_text(hjust=.5),
        plot.subtitle=element_text(hjust=.5))

#
#Performing one-way ANOVAs by Region. What's the critical value for the overall tests?
Domestic <- subset(HBAT_3, Region=="Domestic")
DomesticAOV <- aov(data = Domestic, Recommend ~ Customer)
summary(DomesticAOV)
TukeyHSD(DomesticAOV, conf.level = .975)

#
Intl<- subset(HBAT_3, Region=="International")
IntlAOV <- aov(data = Intl, Recommend ~ Customer)
summary(IntlAOV)
TukeyHSD(IntlAOV, conf.level = .975)

