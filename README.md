# ig.degree.betweenness <a href='https://github.com/benyamindsmith/ig.degree.betweeness'><img src='https://github.com/benyamindsmith/ig.degree.betweenness/raw/main/utils/png/hex_sticker.png' align="right" height="350" /></a>

[![arXiv](https://img.shields.io/badge/arXiv-2411.01394-b31b1b.svg?logo=arxiv)](https://arxiv.org/abs/2411.01394)
[![UTJPH](https://img.shields.io/badge/UTJPH-10.33137%2Futjph.v5i1.44130-1f618d)](https://doi.org/10.33137/utjph.v5i1.44130)
[![CJS](https://img.shields.io/badge/CJS-10.1002%2Fcjs.70060-991915)](https://doi.org/10.1002/cjs.70060)

[![CRAN status](https://img.shields.io/cran/v/ig.degree.betweenness.svg?logo=r&logoColor=white&color=276dc3)](https://cran.r-project.org/package=ig.degree.closeness)
[![R-CMD-check](https://img.shields.io/github/actions/workflow/status/benyamindsmith/ig.cluster.closeness/R-CMD-check.yaml?logo=github)](https://github.com/benyamindsmith/ig.cluster.closeness/actions/workflows/R-CMD-check.yaml)

[![downloads](https://cranlogs.r-pkg.org/badges/ig.degree.betweenness)](https://shinyus.ipub.com/cranview/)
[![total](https://cranlogs.r-pkg.org/badges/grand-total/ig.degree.betweenness)](https://shinyus.ipub.com/cranview/)

An R package for the implementation of the "Smith-Pittman" (2024) community detection algorithm. Also known as the **node degree+edge betweenness** algorithm. Compatible with the igraph ecosystem. 

- For the Python implementation, see [`ig_degree_betweenness_py`](https://github.com/benyamindsmith/ig_degree_betweenness_py). 
- For the C implementation, see [`ig_degree_betweenness_c`](https://github.com/benyamindsmith/ig_degree_betweenness_c)

# Algorithm Visualizations 

How the Smith-Pittman algorithm works:

<a href="https://github.com/benyamindsmith/ig.degree.betweenness">
  <img src="https://raw.githubusercontent.com/benyamindsmith/ig.degree.betweenness/main/utils/png/smith_pittman_algorithm.png" height="300" alt="Smith-Pittman Algorithm Analysis">
</a>

<a href="https://github.com/benyamindsmith/ig.degree.betweenness">
  <img src="https://raw.githubusercontent.com/benyamindsmith/ig.degree.betweenness/main/utils/png/smith_pittman_algorithm_directed.png" height="610" alt="Directed Algorithm Analysis">
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

# Citation

To cite package ‘ig.degree.betweenness’ in publications use:

>  Smith B, Pittman T, Xu W (2024). “Centrality in Collaboration: community detection
  for oncology researchers.” _University of Toronto Journal of Public Health_,
  *5*(1). doi:10.33137/utjph.v5i1.44130
> 
> Smith B, Pittman T, Xu W (2026). “Detecting communities when order and direction
  matter in social network analysis.” _Canadian Journal of Statistics_, *n/a*(n/a),
  e70060. doi:10.1002/cjs.70060

A BibTeX entry for LaTeX users is

```

  @Article{Smith_Pittman_Xu_2024,
    title = {Centrality in Collaboration: community detection for oncology researchers},
    author = {Benjamin Smith and Tyler Pittman and Wei Xu},
    journal = {University of Toronto Journal of Public Health},
    volume = {5},
    number = {1},
    year = {2024},
    month = {nov},
    doi = {10.33137/utjph.v5i1.44130},
    url = {https://utjph.com/index.php/utjph/article/view/44130},
  }
  
   @Article{Smith_Pittman_Xu_2026,
    title = {Detecting communities when order and direction matter in social network analysis},
    author = {Benjamin Smith and Tyler Pittman and Wei Xu},
    journal = {Canadian Journal of Statistics},
    volume = {n/a},
    number = {n/a},
    pages = {e70060},
    year = {2026},
    doi = {https://doi.org/10.1002/cjs.70060},
    url = {https://onlinelibrary.wiley.com/doi/abs/10.1002/cjs.70060},
    eprint = {https://onlinelibrary.wiley.com/doi/pdf/10.1002/cjs.70060},
    keywords = {Community detection, directed networks, edge betweenness, modularity, node degree},
  }

```
