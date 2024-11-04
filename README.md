# ig.degree.betweenness <a href='https://github.com/benyamindsmith/ig.degree.betweeness'><img src='https://github.com/benyamindsmith/ig.degree.betweenness/raw/main/utils/png/hex_sticker.png' align="right" height="300" /></a>


[![](https://www.r-pkg.org/badges/version/ig.degree.betweeness?color=red)](https://cran.r-project.org/package=ig.degree.betweeness) 
[![R-CMD-check](https://github.com/benyamindsmith/ig.cluster.closeness/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/benyamindsmith/ig.cluster.closeness/actions/workflows/R-CMD-check.yaml)
[![arXiv](https://img.shields.io/badge/arXiv-todo-b31b1b.svg)](https://arxiv.org/abs/todo)
[![downloads](https://cranlogs.r-pkg.org/badges/ig.degree.betweenness)](https://shinyus.ipub.com/cranview/)
[![total](https://cranlogs.r-pkg.org/badges/grand-total/ig.degree.betweenness)](https://shinyus.ipub.com/cranview/)


An R package for the implementation of the "Smith-Pittman" community detection algorithm. Compatible with the igraph ecosystem.

<a> 
<img src='https://github.com/benyamindsmith/ig.degree.betweenness/assets/46410142/37f82c83-1600-4e9f-913e-5e43bbe90427', height = "300"/>
</a>

<a> 
<img src='https://github.com/user-attachments/assets/e0d06401-3da3-4e0f-9b9e-12b3ac477848' height = "580"/>
</a>

## Installing this package

To install the stable release of this package from CRAN (coming soon) run: 

```r
install.packages("ig.degree.betweenness")
```

To install the development version of this package run: 

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
