# ig.degree.betweenness <a href='https://github.com/benyamindsmith/ig.degree.betweeness'><img src='https://github.com/benyamindsmith/ig.degree.betweenness/raw/main/utils/png/hex_sticker.png' align="right" height="300" /></a>


[![](https://www.r-pkg.org/badges/version/ig.degree.betweenness?color=red)](https://cran.r-project.org/package=ig.degree.betweenness) 
[![R-CMD-check](https://github.com/benyamindsmith/ig.cluster.closeness/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/benyamindsmith/ig.cluster.closeness/actions/workflows/R-CMD-check.yaml)
[![arXiv](https://img.shields.io/badge/arXiv-2411.01394-b31b1b.svg)](https://arxiv.org/abs/2411.01394)
[![downloads](https://cranlogs.r-pkg.org/badges/ig.degree.betweenness)](https://shinyus.ipub.com/cranview/)
[![total](https://cranlogs.r-pkg.org/badges/grand-total/ig.degree.betweenness)](https://shinyus.ipub.com/cranview/)


An R package for the implementation of the "Smith-Pittman" (2024) community detection algorithm. Also known as the **node degree+edge betweenness** algorithm. Compatible with the igraph ecosystem. 

- For the Python implementation, see [`ig_degree_betweenness_py`](https://github.com/benyamindsmith/ig_degree_betweenness_py). 
- For the C implementation, see [`ig_degree_betweenness_c`](https://github.com/benyamindsmith/ig_degree_betweenness_c)

<a> 
<img src='https://github.com/benyamindsmith/ig.degree.betweenness/assets/46410142/37f82c83-1600-4e9f-913e-5e43bbe90427', height = "300"/>
</a>

<a> 
<img src='https://github.com/user-attachments/assets/63187b8f-58af-4c08-8b80-8a31b945899a' height = "610"/>
</a>

## Installing this package

To install the stable release of this package from CRAN run: 

```r
install.packages("ig.degree.betweenness")
```

To install the development version of this package run: 

```r
# install.packages("devtools")
devtools::install_github("benyamindsmith/ig.degree.betweenness")
```

## Sample Usage

Applying the **node degree+edge betweenness** algorithm can be done by making use of the `cluster_degree_betweenness()`. 

An example of using the code is: 

```r
library(igraphdata)
library(ig.degree.betweenness)

data("karate")

sp <- cluster_degree_betweenness(karate)
plot(
sp,
karate,
main= "Node degree+edge betweenness clustering"
)
```

<a> 
<img src='https://github.com/user-attachments/assets/b247dd3a-9dcc-4d3c-a1f2-7c2ec92f03de'  height = "400" />
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
main= "Node degree+edge betweenness clustering for UK faculty"
)
```

<a> 
<img src=
'https://github.com/user-attachments/assets/2a982de0-e98e-4ef4-847d-2918cf95b9a5' height = "500" />
</a>
