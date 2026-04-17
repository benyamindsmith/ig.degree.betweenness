# ig.degree.betweenness [![](https://github.com/benyamindsmith/ig.degree.betweenness/raw/main/utils/png/hex_sticker.png)](https://github.com/benyamindsmith/ig.degree.betweeness)

[![arXiv](https://img.shields.io/badge/arXiv-2411.01394-b31b1b.svg)](https://arxiv.org/abs/2411.01394)

[![CRAN
status](https://www.r-pkg.org/badges/version/ig.degree.betweenness?color=blue)](https://cran.r-project.org/package=ig.degree.closeness)
[![R-CMD-check](https://github.com/benyamindsmith/ig.cluster.closeness/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/benyamindsmith/ig.cluster.closeness/actions/workflows/R-CMD-check.yaml)

[![downloads](https://cranlogs.r-pkg.org/badges/ig.degree.betweenness)](https://shinyus.ipub.com/cranview/)
[![total](https://cranlogs.r-pkg.org/badges/grand-total/ig.degree.betweenness)](https://shinyus.ipub.com/cranview/)

An R package for the implementation of the “Smith-Pittman” (2024)
community detection algorithm. Also known as the **node degree+edge
betweenness** algorithm. Compatible with the igraph ecosystem.

- For the Python implementation, see
  [`ig_degree_betweenness_py`](https://github.com/benyamindsmith/ig_degree_betweenness_py).
- For the C implementation, see
  [`ig_degree_betweenness_c`](https://github.com/benyamindsmith/ig_degree_betweenness_c)

# Algorithm Visualizations

How the Smith-Pittman algorithm works:

[![Smith-Pittman Algorithm
Analysis](https://raw.githubusercontent.com/benyamindsmith/ig.degree.betweenness/main/utils/png/smith_pittman_algorithm.png)](https://github.com/benyamindsmith/ig.degree.betweenness)

[![Directed Algorithm
Analysis](https://raw.githubusercontent.com/benyamindsmith/ig.degree.betweenness/main/utils/png/smith_pittman_algorithm_directed.png)](https://github.com/benyamindsmith/ig.degree.betweenness)
\## Installing this package

To install the stable release of this package from CRAN run:

``` r
install.packages("ig.degree.betweenness")
```

To install the development version of this package run:

``` r
# install.packages("devtools")
devtools::install_github("benyamindsmith/ig.degree.betweenness")
```

## Sample Usage

Applying the **node degree+edge betweenness** algorithm can be done by
making use of the
[`cluster_degree_betweenness()`](https://benyamindsmith.github.io/ig.degree.betweenness/reference/cluster_degree_betweenness.md).

An example of using the code is:

``` r
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

![](https://github.com/user-attachments/assets/b247dd3a-9dcc-4d3c-a1f2-7c2ec92f03de)

# Citation

To cite package ‘ig.degree.betweenness’ in publications use:

> Smith, Pittman, and Xu (2024). Centrality in Collaboration: A Novel
> Algorithm for Social Partitioning Gradients in Community Detection for
> Multiple Oncology Clinical Trial Enrollments arXiv:2411.01394.

A BibTeX entry for LaTeX users is

    @Misc{Smith_Pittman_Xu_2024,
        title = {Centrality in Collaboration: A Novel Algorithm for Social Partitioning Gradients in Community Detection for Multiple Oncology Clinical Trial Enrollments},
        author = {Benjamin Smith and Tyler Pittman and Wei Xu},
        year = {2024},
        month = {Nov},
        note = {arXiv:2411.01394},
        url = {https://arxiv.org/abs/2411.01394},
      }
