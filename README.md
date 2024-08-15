# ig.degree.betweenness <a href='https://github.com/benyamindsmith/ig.degree.betweeness'><img src='https://github.com/benyamindsmith/ig.degree.betweenness/raw/main/utils/png/hex_sticker.png' align="right" height="200" /></a>


[![](https://www.r-pkg.org/badges/version/ig.degree.betweeness?color=red)](https://cran.r-project.org/package=ig.degree.betweeness) 
[![R-CMD-check](https://github.com/benyamindsmith/ig.cluster.closeness/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/benyamindsmith/ig.cluster.closeness/actions/workflows/R-CMD-check.yaml)

An R package for the implementation of the "Smith-Pittman" community detection algortihm. Compatable with the igraph ecosystem.

<a> 
<img src='https://github.com/benyamindsmith/ig.degree.betweenness/assets/46410142/37f82c83-1600-4e9f-913e-5e43bbe90427', height = "300"/>
</a>

## Installing this package

```r
# install.packages("devtools")
devtools::install_github("benyamindsmith/ig.degree.betweenness")
```

## Sample Usage

Applying the Smith-Pittman algorithm can be done by making use of the `cluster_degree_betweenness()`. 

An example of using the code is: 

```r
library(igraphdata)
library(ig.degree.betweenness)

data("karate")

sp <- cluster_degree_betweenness(karate)
plot(
sp,
karate,
main= "Smith-Pittman Clustering"
)
```

<a> 
<img src='https://github.com/benyamindsmith/ig.degree.betweenness/assets/46410142/3ad89bb8-5082-4c58-ab9f-277d562ddb12'  height = "400" />
</a>

# Limitations

The present limitations of using this algorithm is that graphs are required to be labeled for the operations to work. For unlabeled graphs, graphs can be prepared with the `prep_unlabled_graph()` function. 

Example:

```r
library(igraph)
library(igraphdata)
library(ig.degree.betweenness)
data("UKfaculty")
# Making graph undirected so it looks nicer when its plotted
uk_faculty <- prep_unlabeled_graph(UKfaculty) |>
  as.undirected()

ndb <- cluster_degree_betweenness(uk_faculty)

plot(
ndb,
uk_faculty,
main= "Smith-Pittman Clustering for UK Faculty"
)
```

<a> 
<img src=
'https://github.com/benyamindsmith/ig.degree.betweenness/assets/46410142/91bcc1f4-7dfc-42ea-8d48-dcd4b3fb947e' height = "500" />
</a>
