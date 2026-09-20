# Ozone_regression

TP de régression linéaire multiple sur les données d'ozone (ECM 3A-DDEFi), basé sur *Régression avec R* de Cornillon & Matzner-Lober.

## Contenu

- [`TP1_regression_ozone.R`](TP1_regression_ozone.R) — script R complet du TP : import des données, statistiques descriptives, tests de normalité, régression simple et multiple, diagnostics des résidus (homoscédasticité, autocorrélation, points influents), sélection de variables.
- [`TP1_rendu.md`](TP1_rendu.md) — compte-rendu détaillé, question par question, avec le code, les résultats obtenus et leur interprétation.
- [`ozone.csv`](ozone.csv) — jeu de données utilisé (mesures journalières de température, nébulosité, vent, pluie et pic d'ozone).

## Variables du jeu de données

| Variable | Description |
|---|---|
| `maxO3` | Maximum journalier d'ozone (variable à expliquer) |
| `T9`, `T12`, `T15` | Température à 9h / 12h / 15h |
| `Ne9`, `Ne12`, `Ne15` | Nébulosité (échelle 0-8) |
| `Vx9`, `Vx12`, `Vx15` | Projection du vent sur l'axe Est-Ouest |
| `maxO3v` | Maximum d'ozone de la veille |
| `vent` | Direction du vent (Nord/Est/Ouest/Sud) |
| `pluie` | Sec / Pluie |

## Utilisation

Le fichier `ozone.csv` est séparé par des points-virgules avec une virgule comme séparateur décimal (format français) :

```r
ozone <- read.csv2("ozone.csv")
```

Puis exécuter `TP1_regression_ozone.R` (par exemple avec `source()`), qui reproduit l'ensemble des analyses décrites dans `TP1_rendu.md`.

### Packages R requis

```r
install.packages(c("nortest", "lmtest", "leaps"))
```

## Résumé des résultats

Après diagnostic complet du modèle de régression multiple (résidus, homoscédasticité, autocorrélation, colinéarité), un modèle réduit à 4 variables (température, nébulosité, vent, ozone de la veille) explique presque aussi bien `maxO3` que le modèle complet à 14 variables, tout en étant plus simple et plus interprétable. Le détail de l'analyse est disponible dans [`TP1_rendu.md`](TP1_rendu.md).
