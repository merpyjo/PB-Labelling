#Set working directory
setwd("C:/Users/Jo/Documents/Sync/Faunalytics/A - PB Labelling/Stage 3/Data")

#Load library
library("psych")
library("ggplot2")
library("tidyverse")
library("ggthemes")
library("stargazer")
library("lmSupport")
library("gridExtra")
library("cowplot")

#Load data
load('PB Labelling Data - long cleaned.Rdata')


#REMOVE VEG*NS
ldata <- ldata[ldata$vegn == "non-vegn", ] #keeps only non-vegns

ldata <- as.tibble(ldata)

#########################################
#Standardize numeric variables

names(ldata)
ldata <- mutate(ldata, zage = scale(age), zlabel.score = scale(label.score), zhealth = scale(health), zanimals = scale(animals),
                ztaste = scale(taste), zenv = scale(env))


#########################################
#Create dummy-coded and effect-coded variables

str(ldata)

ldata$reg.e <- C(ldata$Region, sum) #creates effect codes for Region
attributes(ldata$reg.e)
ldata$reg.d <- C(ldata$Region, treatment) #creates dummy codes for Region
attributes(ldata$reg.d)

ldata$eth.race.e <- C(ldata$eth.race2, sum) #creates effect codes for eth.race
describe(ldata$eth.race.e)
#second set of effect codes for looking at 'other' category
ldata$eth.race2alt <- factor(ldata$eth.race2, levels = c("Other", "White", "Black", "Hispanic")) #reorder variable
describe(ldata$eth.race2alt) #check
ldata$eth.race.e2 <- C(ldata$eth.race2alt, sum) #effect codes for reordered variable
attributes(ldata$eth.race.e2)

ldata$label.e <- C(ldata$label, sum) #creates effect codes for label
attributes(ldata$label.e)


#############OVERALL MODEL###############
##########NOT PRE-REGISTERED#############

###Overall regression to look for interactions by label and demographics
overall.model <- lm(label.score ~ label.e*gender1*zage + label.e*eth.race.e + label.e*reg.e + label.e*as.numeric(income) +
                      label.e*alt.cons, ldata)
stargazer(overall.model, type = "text")

#Create dataset with cases removed listwise so that n is the same for all steps
ldata.exc <- filter(ldata, !is.na(gender1) & !is.na(zage) & !is.na(eth.race.e) & !is.na(reg.e) & !is.na(income) & !is.na(alt.cons))

#Original model (just label as predictor since the average of all 8 label scores for each participant is 0 by design)
overall.model1 <- lm(label.score ~ label.e + gender1*zage + eth.race.e + reg.e + as.numeric(income) + alt.cons, ldata.exc)

#Impact of gender x age
overall.model2 <- lm(label.score ~ label.e*gender1*zage + eth.race.e + reg.e + as.numeric(income) + alt.cons, ldata.exc)
compare.models <- modelCompare(overall.model1, overall.model2)
stargazer(overall.model1, overall.model2, type = "text", 
          add.lines = list(c("SSE (Compact) = ", round(compare.models$sseC, 2)),
                           c("SSE (Augmented) = ", round(compare.models$sseA, 2)),
                           c("Delta R-Squared = ", round(compare.models$DeltaR2, 3)),
                           c("Partial Eta-Squared (PRE) = ", round(compare.models$PRE, 3)),
                           c(paste0("F(", compare.models$nDF, ",", compare.models$dDF, ") = "), paste0(round(compare.models$Fstat, 2), ",")),
                           c("p = ", compare.models$p)))

#Impact of ethnicity/race
overall.model3 <- lm(label.score ~ gender1*zage + label.e*eth.race.e + reg.e + as.numeric(income) + alt.cons, ldata.exc)
compare.models <- modelCompare(overall.model1, overall.model3)
stargazer(overall.model1, overall.model3, type = "text", 
          add.lines = list(c("SSE (Compact) = ", round(compare.models$sseC, 2)),
                           c("SSE (Augmented) = ", round(compare.models$sseA, 2)),
                           c("Delta R-Squared = ", round(compare.models$DeltaR2, 3)),
                           c("Partial Eta-Squared (PRE) = ", round(compare.models$PRE, 3)),
                           c(paste0("F(", compare.models$nDF, ",", compare.models$dDF, ") = "), paste0(round(compare.models$Fstat, 2), ",")),
                           c("p = ", compare.models$p)))

#Impact of region
overall.model4 <- lm(label.score ~ gender1*zage + eth.race.e + label.e*reg.e + as.numeric(income) + alt.cons, ldata.exc)
compare.models <- modelCompare(overall.model1, overall.model4)
stargazer(overall.model1, overall.model4, type = "text", 
          add.lines = list(c("SSE (Compact) = ", round(compare.models$sseC, 2)),
                           c("SSE (Augmented) = ", round(compare.models$sseA, 2)),
                           c("Delta R-Squared = ", round(compare.models$DeltaR2, 3)),
                           c("Partial Eta-Squared (PRE) = ", round(compare.models$PRE, 3)),
                           c(paste0("F(", compare.models$nDF, ",", compare.models$dDF, ") = "), paste0(round(compare.models$Fstat, 2), ",")),
                           c("p = ", compare.models$p)))

#Impact of income
overall.model5 <- lm(label.score ~ gender1*zage + eth.race.e + reg.e + label.e*as.numeric(income) + alt.cons, ldata.exc)
compare.models <- modelCompare(overall.model1, overall.model5)
stargazer(overall.model1, overall.model5, type = "text", 
          add.lines = list(c("SSE (Compact) = ", round(compare.models$sseC, 2)),
                           c("SSE (Augmented) = ", round(compare.models$sseA, 2)),
                           c("Delta R-Squared = ", round(compare.models$DeltaR2, 3)),
                           c("Partial Eta-Squared (PRE) = ", round(compare.models$PRE, 3)),
                           c(paste0("F(", compare.models$nDF, ",", compare.models$dDF, ") = "), paste0(round(compare.models$Fstat, 2), ",")),
                           c("p = ", compare.models$p)))

#Impact of alternative consumption status
overall.model6 <- lm(label.score ~ gender1*zage + eth.race.e + reg.e + as.numeric(income) + label.e*alt.cons, ldata.exc)
compare.models <- modelCompare(overall.model1, overall.model6)
stargazer(overall.model1, overall.model6, type = "text", 
          add.lines = list(c("SSE (Compact) = ", round(compare.models$sseC, 2)),
                           c("SSE (Augmented) = ", round(compare.models$sseA, 2)),
                           c("Delta R-Squared = ", round(compare.models$DeltaR2, 3)),
                           c("Partial Eta-Squared (PRE) = ", round(compare.models$PRE, 3)),
                           c(paste0("F(", compare.models$nDF, ",", compare.models$dDF, ") = "), paste0(round(compare.models$Fstat, 2), ",")),
                           c("p = ", compare.models$p)))



##########INDIVIDUAL LABELS##############
###MODELS (PLOTS BELOW)

#H2a: VEGAN
#Pre-registered questions:
#Q2: Do younger men differ from other demographics in their preferences?
#Q3: Do people who currently eat animal product alternatives differ in their preferences from those who do not?
model.h2a <- lm(label.score ~ gender1*zage + eth.race.e + reg.e + as.numeric(income) + alt.cons, filter(ldata, label == "vegan"))
stargazer(model.h2a, type = "text")

#Testing main effect of ethnicity
model.h2a.noeth <- lm(label.score ~ gender1*zage + reg.e + as.numeric(income) + alt.cons, filter(ldata, label == "vegan"))
compare.models <- modelCompare(model.h2a.noeth, model.h2a)
#recode to look at 'other' ethnicity
model.h2a.rec <- lm(label.score ~ gender1*zage + eth.race.e2 + reg.e + as.numeric(income) + alt.cons, filter(ldata, label == "vegan"))
stargazer(model.h2a.rec, type = "text")


#H2b: PLANT-BASED
#Pre-registered questions:
#Q2: Do younger men differ from other demographics in their preferences?
#Q3: Do people who currently eat animal product alternatives differ in their preferences from those who do not?
model.h2b <- lm(label.score ~ gender1*zage + eth.race.e + reg.e + as.numeric(income) + alt.cons, filter(ldata, label == "pb"))
stargazer(model.h2b, type = "text")

#Testing main effect of ethnicity
model.h2b.noeth <- lm(label.score ~ gender1*zage + reg.e + as.numeric(income) + alt.cons, filter(ldata, label == "pb"))
compare.models <- modelCompare(model.h2b.noeth, model.h2b)


#H2c: DIRECT PROTEIN
#Pre-registered questions:
#Q2: Do younger men differ from other demographics in their preferences?
#Q3: Do people who currently eat animal product alternatives differ in their preferences from those who do not?
model.h2c <- lm(label.score ~ gender1*zage + eth.race.e + reg.e + as.numeric(income) + alt.cons, filter(ldata, label == "dp"))
stargazer(model.h2c, type = "text")

#Testing main effect of ethnicity
model.h2c.noeth <- lm(label.score ~ gender1*zage + reg.e + as.numeric(income) + alt.cons, filter(ldata, label == "dp"))
compare.models <- modelCompare(model.h2c.noeth, model.h2c)

stargazer(model.h2a, model.h2b, model.h2c, type = "text", column.labels = c("Vegan", "PB", "DP"))


#FEEL-GOOD
model.fg <- lm(label.score ~ gender1*zage + eth.race.e + reg.e + as.numeric(income) + alt.cons, filter(ldata, label == "fg"))
stargazer(model.fg, type = "text")

#Testing main effect of ethnicity
model.fg.noeth <- lm(label.score ~ gender1*zage + reg.e + as.numeric(income) + alt.cons, filter(ldata, label == "fg"))
compare.models <- modelCompare(model.fg.noeth, model.fg)
#recode to look at 'other' ethnicity (because ME was marginal)
model.fg.rec <- lm(label.score ~ gender1*zage + eth.race.e2 + reg.e + as.numeric(income) + alt.cons, filter(ldata, label == "fg"))
stargazer(model.fg.rec, type = "text")


#KOJO
model.kojo <- lm(label.score ~ gender1*zage + eth.race.e + reg.e + as.numeric(income) + alt.cons, filter(ldata, label == "kojo"))
stargazer(model.kojo, type = "text")

#Testing main effect of ethnicity
model.kojo.noeth <- lm(label.score ~ gender1*zage + reg.e + as.numeric(income) + alt.cons, filter(ldata, label == "kojo"))
compare.models <- modelCompare(model.kojo.noeth, model.kojo)


#CLEAN
model.clean <- lm(label.score ~ gender1*zage + eth.race.e + reg.e + as.numeric(income) + alt.cons, filter(ldata, label == "clean"))
stargazer(model.clean, type = "text")

#Testing main effect of ethnicity
model.clean.noeth <- lm(label.score ~ gender1*zage + reg.e + as.numeric(income) + alt.cons, filter(ldata, label == "clean"))
compare.models <- modelCompare(model.clean.noeth, model.clean)


#PLANET-FRIENDLY
model.pf <- lm(label.score ~ gender1*zage + eth.race.e + reg.e + as.numeric(income) + alt.cons, filter(ldata, label == "pf"))
stargazer(model.pf, type = "text")

#Testing main effect of ethnicity
model.pf.noeth <- lm(label.score ~ gender1*zage + reg.e + as.numeric(income) + alt.cons, filter(ldata, label == "pf"))
compare.models <- modelCompare(model.pf.noeth, model.pf)


#ZERO-CHOLESTEROL
model.zc <- lm(label.score ~ gender1*zage + eth.race.e + reg.e + as.numeric(income) + alt.cons, filter(ldata, label == "zc"))
stargazer(model.zc, type = "text")

#Testing main effect of ethnicity
model.zc.noeth <- lm(label.score ~ gender1*zage + reg.e + as.numeric(income) + alt.cons, filter(ldata, label == "zc"))
compare.models <- modelCompare(model.zc.noeth, model.zc)
#recode to look at 'other' ethnicity (because ME was marginal)
model.zc.rec <- lm(label.score ~ gender1*zage + eth.race.e2 + reg.e + as.numeric(income) + alt.cons, filter(ldata, label == "zc"))
stargazer(model.zc.rec, type = "text")


glimpse(ldata)

stargazer(model.fg, model.h2a, model.clean, model.kojo, model.h2c, model.pf, model.zc, model.h2b, 
          type = "text", column.labels = c("FG", "Vegan", "Clean", "Kojo", "DP", "PF", "ZC", "PB"))


####################################
#QUESTION 5

taste.model1 <- lm(label.score ~ zhealth + zanimals + zenv, ldata)
taste.model2 <- lm(label.score ~ zhealth + zanimals + zenv + ztaste, ldata)
compare.models <- modelCompare(taste.model1, taste.model2)
stargazer(overall.model1, overall.model2, type = "text", 
          add.lines = list(c("SSE (Compact) = ", round(compare.models$sseC, 2)),
                           c("SSE (Augmented) = ", round(compare.models$sseA, 2)),
                           c("Delta R-Squared = ", round(compare.models$DeltaR2, 3)),
                           c("Partial Eta-Squared (PRE) = ", round(compare.models$PRE, 3)),
                           c(paste0("F(", compare.models$nDF, ",", compare.models$dDF, ") = "), paste0(round(compare.models$Fstat, 2), ",")),
                           c("p = ", compare.models$p)))

ratings.lm2 <- lm(label.score ~ zhealth + zanimals + zenv + ztaste + gender1*zage + income + eth.race.e + reg.e + alt.cons, ldata)
lm.deltaR2(ratings.lm, ratings.lm2)
stargazer(ratings.lm, ratings.lm2, type = "text")

rat.fg1 <- lm(label.score ~ zhealth + zanimals + zenv + ztaste, filter(ldata, label == "fg"))
rat.fg2 <- lm(label.score ~ zhealth + zanimals + zenv + ztaste + gender1*zage + income + eth.race.e + reg.e + alt.cons, 
             filter(ldata, label == "fg"))
stargazer(rat.fg1, rat.fg2, type = "text")

rat.vegan1 <- lm(label.score ~ zhealth + zanimals + zenv + ztaste, filter(ldata, label == "vegan"))
rat.vegan2 <- lm(label.score ~ zhealth + zanimals + zenv + ztaste + gender1*zage + income + eth.race.e + reg.e + alt.cons, 
                filter(ldata, label == "vegan"))
lm.deltaR2(rat.vegan1, rat.vegan2)
stargazer(rat.vegan1, rat.vegan2, type = "text")

###PREDICTING TASTE

#Is perceived tastiness influenced by demographics?
taste.model <- lm(ztaste ~ label.e + gender1*zage + eth.race.e + reg.e + as.numeric(income) + alt.cons, ldata)
stargazer(taste.model, type = "text")


#######################PLOTS#########################

line.fg <- ggplot(filter(ldata, label == "fg" & gender1 != "Other"), aes(x = age, y = label.score)) + 
  geom_smooth(aes(group = gender1, color = gender1), method = "lm") +
  geom_point(aes(color = gender1), size = .3) + 
  labs (x = "", y = "Overall Rating", colour = "Gender") +
  theme(text = element_text(size=20), legend.position = c(.8,1)) +
  coord_cartesian(ylim = c(-6,6)) +
  ggtitle("Feel-Good")
line.fg

line2a <- ggplot(filter(ldata, label == "vegan" & gender1 != "Other"), aes(x = age, y = label.score)) + 
  geom_point(aes(color = gender1), size = .3) + 
  geom_smooth(aes(group = gender1, color = gender1), method = "lm") +
  labs (x = "", y = "Overall Rating") + 
  guides(colour = FALSE) +
  theme(text = element_text(size=20)) +
  coord_cartesian(ylim = c(-6,6)) +
  ggtitle("Vegan")
line2a

line2c <- ggplot(filter(ldata, label == "dp" & gender1 != "Other"), aes(x = age, y = label.score)) + 
  geom_point(aes(color = gender1), size = .3) + 
  geom_smooth(aes(group = gender1, color = gender1), method = "lm") +
  labs (x = "", y = "Overall Rating") + 
  guides(colour = FALSE) +
  theme(text = element_text(size=20)) +
  coord_cartesian(ylim = c(-6,6)) +
  ggtitle("Direct Protein")
line2c

line2b <- ggplot(filter(ldata, label == "pb" & gender1 != "Other"), aes(x = age, y = label.score)) + 
  geom_point(aes(color = gender1), size = .3) + 
  geom_smooth(aes(group = gender1, color = gender1), method = "lm") +
  labs (x = "Age", y = "Overall Rating") + 
  guides(colour = FALSE) +
  theme(text = element_text(size=20)) +
  coord_cartesian(ylim = c(-6,6)) +
  ggtitle("Plant-Based")
line2b

#

line.kojo <- ggplot(filter(ldata, label == "kojo" & gender1 != "Other"), aes(x = age, y = label.score)) + 
  geom_point(aes(color = gender1), size = .3) + 
  geom_smooth(aes(group = gender1, color = gender1), method = "lm") +
  labs (x = "", y = "Overall Rating", colour = "Gender") +
  theme(text = element_text(size=20), legend.position = c(.8,1)) +
  coord_cartesian(ylim = c(-6,6)) +
  ggtitle("Kojo")
line.kojo

line.zc <- ggplot(filter(ldata, label == "zc" & gender1 != "Other"), aes(x = age, y = label.score)) + 
  geom_point(aes(color = gender1), size = .3) + 
  geom_smooth(aes(group = gender1, color = gender1), method = "lm") +
  labs (x = "", y = "Overall Rating") + 
  guides(colour = FALSE) +
  theme(text = element_text(size=20)) +
  coord_cartesian(ylim = c(-6,6)) +
  ggtitle("Zero Cholesterol")
line.zc

line.clean <- ggplot(filter(ldata, label == "clean" & gender1 != "Other"), aes(x = age, y = label.score)) + 
  geom_point(aes(color = gender1), size = .3) + 
  geom_smooth(aes(group = gender1, color = gender1), method = "lm") +
  labs (x = "", y = "Overall Rating") + 
  guides(colour = FALSE) +
  theme(text = element_text(size=20)) +
  coord_cartesian(ylim = c(-6,6)) +
  ggtitle("Clean")
line.clean

line.pf <- ggplot(filter(ldata, label == "pf" & gender1 != "Other"), aes(x = age, y = label.score)) + 
  geom_point(aes(color = gender1), size = .3) + 
  geom_smooth(aes(group = gender1, color = gender1), method = "lm") +
  labs (x = "Age", y = "Overall Rating") + 
  guides(colour = FALSE) +
  theme(text = element_text(size=20)) +
  coord_cartesian(ylim = c(-6,6)) +
  ggtitle("Planet-Friendly")
line.pf


###All plots together

#Output to PNG
png('All Plots 1 - Age by Gender.png', width = 500, height = 1300)
grid.arrange(line.fg, line2a, line2c, line2b, ncol = 1)
dev.off()
png('All Plots 2 - Age by Gender.png', width = 500, height = 1300)
grid.arrange(line.kojo, line.zc, line.clean, line.pf, ncol = 1)
dev.off()


####OUTPUT DATA

write.csv(ldata, file='PB Labelling Data - all variables.csv', row.names=FALSE)
