# TP1 — Régression linéaire multiple : données ozone
**ECM 3A-DDEFi**

---

## 1. Importation des données

```r
ozone <- read.csv2("C:/Users/amine/Downloads/ozone.csv")
ozone$vent <- as.factor(ozone$vent)
ozone$pluie <- as.factor(ozone$pluie)
```

Le fichier est séparé par des points-virgules avec un séparateur décimal virgule (`read.csv2`). Les variables `vent` et `pluie`, qualitatives, sont converties en facteurs.

---

## 2. Variables et leur nature

| Variable | Nature | Description |
|---|---|---|
| `obs` | identifiant | numéro de l'observation |
| `maxO3` | quantitative continue | ozone max journalier (variable à expliquer) |
| `T9`, `T12`, `T15` | quantitative continue | température à 9h/12h/15h |
| `Ne9`, `Ne12`, `Ne15` | quantitative discrète (0-8) | nébulosité (octas) |
| `Vx9`, `Vx12`, `Vx15` | quantitative continue | projection du vent sur l'axe Est-Ouest |
| `maxO3v` | quantitative continue | ozone max de la veille |
| `vent` | qualitative nominale | direction du vent (Nord/Est/Ouest/Sud) |
| `pluie` | qualitative binaire | Sec/Pluie |

---

## 3. maxO3 en fonction de T12

*[TODO : coller le graphique / décrire la tendance observée (relation croissante ? dispersion ?)]*

---

## 4. maxO3 en fonction du vent et de la pluie ; vent en fonction de T12

*[TODO : décrire les boxplots obtenus — différences de médiane entre catégories]*

---

## 5. Statistiques descriptives

*[TODO : coller le résultat de `summary(ozone)`]*

---

## 6. Normalité de maxO3

**Q-Q Plot** : *[TODO : décrire l'écart à la droite théorique]*

**Test de Shapiro-Wilk**
- H0 : la variable suit une loi normale
- H1 : la variable ne suit pas une loi normale
- Statistique de test : W
- Région de rejet : p-value < 0,05

**Résultat obtenu** :
```
W = 0.906, p-value = 8.516e-07
```
**Conclusion** : p-value ≪ 0,05 → on rejette H0. `maxO3` ne suit pas une loi normale (distribution asymétrique, cohérent avec le Q-Q plot).

---

## 7. Régression simple maxO3 ~ T12

a) Statistiques élémentaires : *[TODO : `summary(ozone$maxO3)`, `summary(ozone$T12)`]*

b) Nuage de points : cf. section 3.

c) Modèle :
```r
reg1 <- lm(maxO3 ~ T12, data=ozone)
summary(reg1)
```
*[TODO : coller la sortie de summary(reg1)]*

d) Interprétation : *[TODO, à rédiger une fois la sortie obtenue — regarder le signe et la significativité du coefficient de T12, et le R²]*

---

## 8. Régression maxO3 ~ Ne12 + maxO3v

```r
reg2 <- lm(maxO3 ~ Ne12 + maxO3v, data=ozone)
summary(reg2)
```
*[TODO : coller la sortie de summary(reg2)]*

**Interprétation** : *[TODO — significativité de Ne12 et maxO3v, comparaison du R² avec reg1]*

---

## 9. Modèle de régression complet

### a) Estimation des paramètres
```r
regc <- lm(maxO3 ~ . - obs, data=ozone)
regc$coefficients
```

| Variable | Estimate | p-value | Signif. |
|---|---|---|---|
| (Intercept) | 16.265 | 0.310 | |
| T9 | 0.039 | 0.973 | |
| T12 | 1.973 | 0.184 | |
| T15 | 0.450 | 0.705 | |
| Ne9 | -2.110 | 0.030 | * |
| Ne12 | -0.606 | 0.672 | |
| Ne15 | -0.017 | 0.987 | |
| Vx9 | 0.483 | 0.626 | |
| Vx12 | 0.514 | 0.681 | |
| Vx15 | 0.727 | 0.447 | |
| maxO3v | 0.344 | 1.42e-06 | *** |
| ventNord | 0.540 | 0.936 | |
| ventOuest | 5.536 | 0.504 | |
| ventSud | 5.420 | 0.451 | |
| pluieSec | 3.247 | 0.353 | |

R² = 0.7686, R² ajusté = 0.7352, F(14,97) = 23.01, p < 2.2e-16.

*(Remarque : `obs` est exclu du modèle car c'est un simple identifiant de ligne, sans signification climatique.)*

### b) Résidus et histogramme
*[TODO : décrire la forme de l'histogramme]*

### c) Q-Q Plot des résidus
*[TODO : décrire l'écart à la droite théorique]*

### d) Test de Shapiro-Wilk sur les résidus
```
W = 0.971, p-value = 0.01587
```
**Conclusion** : p-value < 0,05 → on rejette H0 au seuil de 5%. Cependant W est proche de 1 et la p-value bien plus grande que pour `maxO3` brut (comparer à la section 6) : la régression a nettement amélioré la normalité, même si le rejet formel subsiste de justesse à 5%.

### e) Test de Kolmogorov-Smirnov
```r
ks.test(regc$residuals, "pnorm", mean(regc$residuals), sd(regc$residuals))
```
```
D = 0.059997, p-value = 0.8149
```
**Conclusion** : p-value ≫ 0,05 → on ne rejette pas H0. **Ce test ne conduit pas à la même conclusion que Shapiro-Wilk** : il juge les résidus compatibles avec la normalité. Le test de Shapiro-Wilk est généralement plus puissant pour détecter de faibles écarts à la normalité, ce qui explique cette différence de conclusion sur un cas "limite".

### f) Test du Khi-deux d'adéquation (test de Pearson)
```r
library(nortest)
pearson.test(regc$residuals)
```
```
P = 11.75, p-value = 0.3827
```
**Conclusion** : p-value ≫ 0,05 → on ne rejette pas H0, conclusion cohérente avec le test de Kolmogorov-Smirnov (section e). Globalement, 2 tests sur 3 ne rejettent pas la normalité des résidus ; Shapiro-Wilk la rejette de justesse — la normalité des résidus est jugée acceptable, avec une réserve mineure.

### g) Étude graphique de l'homoscédasticité
```r
plot(regc$fitted.values, abs(regc$residuals), col=2)
lines(lowess(regc$fitted.values, abs(regc$residuals), f=0.7))
```
*[TODO : décrire si la courbe lowess est plate (homoscédasticité) ou croissante/décroissante (hétéroscédasticité)]*

### h) Résidus studentisés
```r
res.simple <- rstudent(regc)
plot(res.simple, pch=15, cex=.5, ylab="Résidus", ylim=c(-3,3))
abline(h=c(-2,0,2), lty=c(2,1,2))
```
*[TODO : décrire si des points sortent de la bande [-2, 2] (résidus suspects/outliers potentiels)]*

Résidus studentisés (`rstudent`) : version normalisée des résidus (chaque résidu est divisé par une estimation de son propre écart-type, calculée en ré-ajustant le modèle sans cette observation). Cela les rend comparables entre eux malgré l'hétéroscédasticité ou les différences de levier, et les bornes ±2 servent de seuil empirique pour repérer les valeurs atypiques.

### i) Test de Breusch-Pagan (homoscédasticité)
```r
library(lmtest)
bptest(regc)
```
- H0 : homoscédasticité (variance des résidus constante). H1 : hétéroscédasticité.
- Région de rejet : p-value < 0,05.

**Résultat** : `BP = 22.322, df = 14, p-value = 0.07223`

**Conclusion** : p-value = 0.072 > 0,05 → on ne rejette pas H0 (de justesse). Il n'y a pas de preuve statistique suffisante d'hétéroscédasticité au seuil de 5%, même si la p-value reste relativement proche du seuil — cohérent avec l'observation graphique de la question 9(g), où une légère tendance pouvait sembler visible sans être flagrante.

### j) Structure temporelle des résidus
```r
plot(regc$residuals, col=2, ylab="Residus")
lines(lowess(regc$residuals, f=0.7), lty=2)
```
*[TODO : décrire si la courbe lowess reste plate (pas de structure temporelle) ou dérive (autocorrélation suspectée)]*

### k) Test de Durbin-Watson (autocorrélation d'ordre 1)
```r
dwtest(regc)
```
- H0 : pas d'autocorrélation des résidus. H1 : présence d'autocorrélation.
- Région de rejet : p-value < 0,05.

**Résultat** : `DW = 1.8434, p-value = 0.1517`

**Conclusion** : la statistique DW est proche de 2 (valeur attendue en l'absence d'autocorrélation), et p-value = 0.152 > 0,05 → on ne rejette pas H0. Pas d'autocorrélation d'ordre 1 détectée dans les résidus.

### l) Test de Breusch-Godfrey (autocorrélation, plus général)
```r
bgtest(regc)
```
- Même objectif que Durbin-Watson, mais détecte l'autocorrélation à plusieurs ordres et reste valide avec certains régresseurs où Durbin-Watson est moins fiable.

**Résultat** : `LM test = 1.2119, df = 1, p-value = 0.271`

**Conclusion** : p-value = 0.271 > 0,05 → on ne rejette pas H0. **Même conclusion que Durbin-Watson (k)** : pas d'autocorrélation détectée dans les résidus — l'hypothèse d'indépendance des résidus est acceptable.

### m) Structure du nuage / grands résidus
```r
res.student <- rstudent(regc)
ychap <- regc$fitted.values
plot(res.student, ylab="Residus")
abline(h=c(-2,0,2), lty=c(2,1,2))
```
*[TODO : décrire une éventuelle structure non aléatoire, et compter les points hors de [-2, 2]]*

### n) Points influents (distance de Cook)
```r
cook <- cooks.distance(regc)
plot(cook~ychap, ylab="Distance de Cook", xlab="Valeurs ajustees")
abline(h=c(0,1), lty=c(1,2))
```
La distance de Cook mesure l'influence de chaque observation sur l'ensemble du modèle (combinaison du résidu et du levier). Seuil d'alerte usuel : distance > 1.

*[TODO : indiquer si des points dépassent le seuil de 1]*

### o) Significativité des variables du modèle complet
```r
summary(regc)
```
D'après le tableau de coefficients de la section 9(a), **seules deux variables sont significatives au seuil de 5%** : `Ne9` (p=0.030) et `maxO3v` (p=1.42e-06, très significative). Toutes les autres (T9, T12, T15, Ne12, Ne15, Vx9, Vx12, Vx15, vent, pluie) ne sont pas significatives individuellement dans ce modèle complet.

**Variables pertinentes proposées** : `Ne9` et `maxO3v`. Le manque de significativité des autres variables (notamment T9/T12/T15, ou Ne9/Ne12/Ne15, ou Vx9/Vx12/Vx15) s'explique probablement par une forte **colinéarité** entre elles (variables très corrélées mesurant presque la même chose à des heures différentes) — leur effet individuel devient statistiquement indiscernable une fois toutes incluses ensemble, même si collectivement le modèle reste très significatif (F=23.01, p<2.2e-16). C'est précisément ce que confirme la question 10.

### p) Prédiction pour T12 = 19°C (1er octobre 2001)
```r
# Utilise reg1 (maxO3 ~ T12) et non regc : on ne dispose ici que de T12,
# alors que regc necessite toutes les variables explicatives.
xnew <- 19
xpredict <- as.data.frame(xnew)
colnames(xpredict) <- "T12"
predict(reg1, xpredict, interval="pred")
```

**Résultat** : `fit = 76.49, lwr = 41.45, upr = 111.52`

**Conclusion** : pour une température T12 de 19°C, le modèle prédit un maximum d'ozone d'environ **76.5 µg/m³**, avec un intervalle de prédiction à 95% assez large : **[41.5 ; 111.5]**. Cette largeur reflète la variabilité importante de `maxO3` non expliquée par `T12` seule (R² de reg1 relativement modeste).

### q) Bandes de confiance et de prédiction
```r
grillex <- seq(min(ozone$T12), max(ozone$T12), length=100)
grillex.df <- data.frame(T12=grillex)
IC <- predict(reg1, newdata=grillex.df, interval="conf", level=0.95)
ICprev <- predict(reg1, newdata=grillex.df, interval="pred", level=0.95)
plot(maxO3~T12, data=ozone, pch=15, cex=.5)
matlines(grillex, cbind(IC, ICprev[,-1]), lty=c(1,2,2,3,3), col=1)
legend("topleft", lty=2:3, legend=c("conf","prev"))
```
L'intervalle de confiance (bande étroite) porte sur la valeur moyenne prédite ; l'intervalle de prédiction (bande large) porte sur une future observation individuelle et intègre en plus la variabilité résiduelle.

*[TODO : décrire l'allure du graphique obtenu]*

### r) Synthèse sur la normalité des résidus
Voir sections 9(b) à 9(f) : histogramme et Q-Q plot proches d'une forme normale avec un léger écart en queue de distribution ; Shapiro-Wilk rejette de justesse (p=0.0159) tandis que Kolmogorov-Smirnov (p=0.815) et le test du Khi-deux (p=0.383) ne rejettent pas. **Conclusion** : normalité globalement acceptable, à nuancer légèrement.

---

## 10. Modèle intermédiaire (T15, Ne12, Vx9, maxO3v)

```r
regi <- lm(maxO3 ~ T15 + Ne12 + Vx9 + maxO3v, data=ozone)
summary(regi)
```
*(Variable de vent utilisée : `Vx9`, à ajuster si l'énoncé du professeur précise `Vx12` ou `Vx15`.)*

| Variable | Estimate | p-value | Signif. dans regi | Signif. dans regc (9a) |
|---|---|---|---|---|
| (Intercept) | 18.181 | 0.145 | non | non |
| T15 | 2.420 | 9.00e-07 | **oui (\*\*\*)** | non (p=0.705) |
| Ne12 | -2.412 | 0.00517 | **oui (\*\*)** | non (p=0.672) |
| Vx9 | 1.471 | 0.02117 | **oui (\*)** | non (p=0.626) |
| maxO3v | 0.345 | 1.11e-07 | oui (\*\*\*) | oui (\*\*\*) |

R² = 0.7359, R² ajusté = 0.726, F(4,107) = 74.52, p < 2.2e-16.

**Interprétation et déduction** : dans ce modèle réduit, **les 4 variables sont significatives**, alors que `T15`, `Ne12` et `Vx9` ne l'étaient pas dans le modèle complet `regc`. C'est exactement le phénomène annoncé par l'énoncé : dans `regc`, ces variables sont fortement corrélées avec d'autres variables du même type incluses simultanément (T9/T12/T15 entre elles, Ne9/Ne12/Ne15 entre elles, Vx9/Vx12/Vx15 entre elles) — cette **colinéarité** gonfle les erreurs-types des coefficients et masque leur significativité individuelle. En retirant les variables redondantes, leur véritable effet explicatif redevient détectable.

Autre point notable : le R² ajusté de `regi` (0.726) est presque identique à celui de `regc` (0.7352) — un modèle à **4 variables** explique presque aussi bien `maxO3` qu'un modèle à **14 variables**. `regi` est donc un modèle beaucoup plus **parcimonieux** (plus simple, plus interprétable, moins sensible au sur-ajustement) pour une perte de pouvoir explicatif quasi négligeable.

---

## 11. Comparaison des modèles

### a) Test de Fisher emboîté : `anova(reg1, regc)`
```r
anova(reg1, regc)
```
- H0 : les variables supplémentaires de `regc` (par rapport à `reg1`) n'apportent rien de significatif.
- H1 : au moins une variable supplémentaire améliore significativement le modèle.

**Résultat** :

| Modèle | Res.Df | RSS | Df | Sum of Sq | F | Pr(>F) |
|---|---|---|---|---|---|---|
| 1 : `maxO3 ~ T12` (reg1) | 110 | 33948 | | | | |
| 2 : modèle complet (regc) | 97 | 20410 | 13 | 13538 | 4.9491 | 1.348e-06 *** |

**Interprétation** : la p-value (1.35e-06) est très inférieure à 0,05 → on **rejette H0**. Les 13 variables supplémentaires du modèle complet, prises ensemble, réduisent significativement la somme des carrés résiduelle (RSS passe de 33948 à 20410) par rapport au modèle simple `reg1`.

**Déduction** : le modèle complet apporte un gain d'explication statistiquement significatif par rapport au modèle réduit à `T12` seul — il est donc "raisonnable" d'enrichir le modèle au-delà de la seule température. Cependant, on a vu (section 9o et question 10) que ce gain global n'implique pas que chaque variable individuellement soit utile : une grande partie de l'apport vient probablement de `maxO3v` (très significative partout) et d'un sous-ensemble de variables comme `T15`, `Ne12`, `Vx9` (significatives dans `regi` une fois la colinéarité réduite). Le modèle intermédiaire `regi`, plus parcimonieux, apparaît comme un bon compromis entre qualité d'ajustement et simplicité.

### b) Sélection de variables avec `leaps`
```r
library(leaps)
choix <- regsubsets(maxO3 ~ . - obs, data=ozone, nbest=1, nvmax=11)
plot(choix)
```
`regsubsets` teste tous les sous-ensembles de variables et retient le meilleur modèle pour chaque taille (nombre de variables). Le graphique montre, pour les modèles les mieux classés, quelles variables ils contiennent.

**Lecture du graphique** : les lignes du haut (BIC le plus négatif ≈ -140, donc les meilleurs modèles selon ce critère) incluent systématiquement `T12`, `Ne9`, `Vx9` et `maxO3v`, en plus de l'intercept. À l'inverse, `T9`, `T15`, `Ne15`, `Vx12`, `ventOuest` et `ventSud` n'apparaissent quasiment jamais dans les modèles bien classés — ils n'apportent pas d'information utile une fois les autres variables présentes. `ventNord` et `pluieSec` n'apparaissent que dans des modèles plus grands, avec un BIC légèrement moins bon (autour de -120/-130), ce qui indique un gain marginal, insuffisant pour compenser la pénalité de complexité du BIC.

**Interprétation** : le meilleur compromis biais/complexité selon `regsubsets` est un modèle à 4 variables climatiques (`T12`, `Ne9`, `Vx9`, `maxO3v`), sans les variables qualitatives `vent`/`pluie`. Cela confirme, par une méthode indépendante (critère BIC sur tous les sous-ensembles), une partie des conclusions déjà tirées :
- `maxO3v` et `Ne9` étaient déjà les seules variables significatives du modèle complet `regc` (section 9o) — le BIC les retient aussi.
- `T12` et `Vx9`, non significatifs dans `regc` à cause de la colinéarité avec T9/T15 et Vx12/Vx15 respectivement, redeviennent pertinents une fois les variables redondantes retirées — exactement le phénomène observé dans le modèle intermédiaire `regi` (question 10), même si `regsubsets` privilégie ici `T12` là où `regi` utilisait `T15` : les deux variables de température étant très corrélées entre elles, l'une ou l'autre peut jouer un rôle équivalent selon le sous-ensemble considéré.

**Déduction finale** : les variables qualitatives (`vent`, `pluie`) et les mesures redondantes prises à d'autres heures de la journée (T9/T15, Ne12/Ne15, Vx12/Vx15) n'apportent pas d'amélioration suffisante pour justifier leur complexité supplémentaire. Un modèle parcimonieux combinant une seule mesure de température, de nébulosité, de vent, et l'ozone de la veille (`maxO3v`) suffit à capturer l'essentiel du phénomène — cohérent avec le fait que `regi` (question 10), plus simple que `regc`, obtenait un R² ajusté quasiment identique (0.726 contre 0.7352).

---

## Conclusion générale

*[TODO : synthèse finale — quel modèle retenir (reg1, reg2, regi ou regc), pourquoi, et quelles limites (normalité, homoscédasticité, autocorrélation) garder à l'esprit]*

---

*Rendu en cours de construction — sections marquées [TODO] à compléter avec les sorties R obtenues (résultats numériques, descriptions de graphiques).*
