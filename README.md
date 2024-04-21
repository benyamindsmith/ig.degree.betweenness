# ig.degree.betweenness <a href='https://github.com/benyamindsmith/ig.degree.betweeness'><img src='https://github.com/benyamindsmith/ig.degree.betweenness/blob/main/inst/png/hex_sticker.png' align="right" height="200" /></a>

An R package for the implementation of the "Smith-Pittman" community detection algortihm. 

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
