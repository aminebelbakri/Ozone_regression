ozone <- read.csv2("C:/Users/amine/Downloads/ozone.csv")

# vent et pluie sont qualitatives : on les convertit en facteurs
# pour que plot() sache tracer des boxplots avec ces variables
ozone$vent <- as.factor(ozone$vent)
ozone$pluie <- as.factor(ozone$pluie)

# ---- Question 2 : variables et leur nature ----
print(names(ozone))
print(head(ozone))
str(ozone)

# ---- Question 3 : maxO3 en fonction de T12 ----
plot(ozone$T12, ozone$maxO3,
     xlab="Temperature a 12h (T12)", ylab="Max ozone (maxO3)",
     main="max03 en fonction de T12")

# ---- Question 4 :max03 en fonction de vent ----
plot(ozone$vent, ozone$maxO3,
     xlab="Le Vent", ylab="Max ozone (maxO3)",
     main="max03 en fonction du vent")
# Max03 en fonction de la pluie
plot(ozone$pluie, ozone$maxO3,
     xlab="La pluie", ylab="Max ozone (maxO3)",
     main="max03 en fonction de la pluie")
#Vent en fonction T12
plot(ozone$vent, ozone$T12,
     xlab="Le vent", ylab="La temperature à 12h",
     main="T12 en fonction du vent")

# ---- Question 5 : statistiques descriptives ----
print(summary(ozone))

# ---- Question 6 : normalite de maxO3 ----
qqnorm(ozone$maxO3, main="Q-Q Plot de maxO3")
qqline(ozone$maxO3)

print(shapiro.test(ozone$maxO3))

# ---- Question 7 : maxO3 et T12 ----
# a) statistiques elementaires
print(summary(ozone$maxO3))
print(summary(ozone$T12))

# b) nuage de points 
plot(ozone$T12, ozone$maxO3)

# c) modele de regression simple : maxO3 explique par T12
reg1 <- lm(maxO3 ~ T12, data=ozone)
print(summary(reg1))

# ---- Question 8 : regression de maxO3 sur Ne12 et maxO3v ----
reg2 <- lm(maxO3 ~ Ne12 + maxO3v, data=ozone)
print(summary(reg2))

# ---- Question 9 : modele de regression complet ----
# a) estimer les parametres du modele complet (on exclut "obs", qui n'est
#    qu'un identifiant de ligne, pas une variable climatique)
regc <- lm(maxO3 ~ . - obs, data=ozone)
print(regc$coefficients)

# b) residus et histogramme
print(head(regc$residuals))
hist(regc$residuals, main="Histogramme des residus", xlab="Residus")

# c) Q-Q plot des residus (comparaison a une loi gaussienne)
qqnorm(regc$residuals, main="Q-Q Plot des residus")
qqline(regc$residuals)

# d) test de Shapiro-Wilk sur les residus
print(shapiro.test(regc$residuals))

# e) test de Kolmogorov-Smirnov sur les residus
print(ks.test(regc$residuals, "pnorm", mean(regc$residuals), sd(regc$residuals)))

# f) test du Khi-deux d'adequation (test de Pearson) pour la normalite
# install.packages("nortest")  # deja installe, plus besoin de relancer
library(nortest)
print(pearson.test(regc$residuals))

# g) etude graphique de l'homoscedasticite des residus
plot(regc$fitted.values, abs(regc$residuals), col=2,
     xlab="Valeurs ajustees", ylab="|Residus|",
     main="Etude de l'homoscedasticite")
lines(lowess(regc$fitted.values, abs(regc$residuals), f=0.7))

# h) etude des résidus studentisés ----
res.simple<- rstudent(regc)
plot(res.simple, pch=15,cex=.5,ylab="Résidus",ylim=c(-3,3))
abline(h=c(-2,0,2),lty=c(2,1,2))

# i) test de Breusch-Pagan
# install.packages("lmtest")  # a executer une seule fois si necessaire
library(lmtest)
print(bptest(regc))

# j) analyse graphique de structuration temporelle des résidus ----
plot(regc$residuals, col=2, ylab="Residus")
lines(lowess(regc$residuals, f=0.7), lty=2)

# k) test de Durbin-Waston
library(lmtest)
print(dwtest(regc))

# l) test de Breush-Godfrey----
print(bgtest(regc))

# m) réperage d'une structure particuliére du nuage ou la présence de "grands" résidus:
res.student <- rstudent(regc)
ychap <- regc$fitted.values
plot(res.student, ylab="Residus", main="Residus studentises (recherche de structure / grands residus)")
abline(h=c(-2,0,2), lty=c(2,1,2))

# n) Reperage d'éventuels points influents----
cook <- cooks.distance(regc)
plot(cook~ychap, ylab="Distance de Cook", xlab="Valeurs ajustees")
abline(h=c(0,1), lty=c(1,2))

# o) analyse de la significativaté des variables 
print(summary(regc))

# p) prediction de niveau d'ozone pour la date du 1er octobre 2001 ----
# Note : on utilise reg1 (maxO3 ~ T12) et non regc, car on ne dispose ici
# que d'une seule valeur (T12=19) ; regc a besoin de toutes les variables.
xnew <- 19
xpredict <- as.data.frame(xnew)
colnames(xpredict) <- "T12"
print(predict(reg1, xpredict, interval="pred"))

# q) bandes de confiance et de prediction (avec reg1, pour rester en 2D vs T12)
grillex <- seq(min(ozone$T12), max(ozone$T12), length=100)
grillex.df <- data.frame(T12=grillex)

IC <- predict(reg1, newdata=grillex.df, interval="conf", level=0.95)
ICprev <- predict(reg1, newdata=grillex.df, interval="pred", level=0.95)

plot(maxO3~T12, data=ozone, pch=15, cex=.5)
matlines(grillex, cbind(IC, ICprev[,-1]), lty=c(1,2,2,3,3), col=1)
legend("topleft", lty=2:3, legend=c("conf","prev"))

# ---- Question 10 : modele intermediaire ----
# NOTE : Vx9 utilise par defaut ; remplacer par Vx12 ou Vx15 si l'enonce le precise autrement
regi <- lm(maxO3 ~ T15 + Ne12 + Vx9 + maxO3v, data=ozone)
print(summary(regi))

# ---- Question 11 : comparaison des modeles ----
# a) test de Fisher entre le modele simple (reg1) et le modele complet (regc)
print(anova(reg1, regc))

# b) selection de variables avec le package leaps
# install.packages("leaps")  # deja installe
library(leaps)
choix <- regsubsets(maxO3 ~ . - obs, data=ozone, nbest=1, nvmax=11)
plot(choix)
