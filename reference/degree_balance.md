# Analyze Degree Balance of a Graph

Computes and summarizes vertex degree distributions for an `igraph`
object. For directed graphs, the function reports in-degree and
out-degree statistics, including their correlation and mean values. For
undirected graphs, only overall degree statistics are reported.

## Usage

``` r
degree_balance(g)
```

## Arguments

- g:

  An `igraph` graph object.

## Value

A list containing:

- `out_degree` Numeric vector of out-degrees (directed graphs only).

- `in_degree` Numeric vector of in-degrees (directed graphs only).

- `degree` Numeric vector of degrees (undirected graphs only).

## Details

If the graph is directed (see
[`igraph::is_directed()`](https://r.igraph.org/reference/is_directed.html)),
the function:

- Computes in-degree and out-degree for each vertex.

- Prints summary statistics for both distributions.

- Reports the correlation between in-degree and out-degree.

- Reports mean in-degree and mean out-degree.

If the graph is undirected, the function:

- Computes the degree for each vertex.

- Prints summary statistics of the degree distribution.

## Examples

``` r
library(igraph)
#> 
#> Attaching package: ‘igraph’
#> The following objects are masked from ‘package:stats’:
#> 
#>     decompose, spectrum
#> The following object is masked from ‘package:base’:
#> 
#>     union
library(ig.degree.betweenness)

# Directed graph example
g_directed <- make_ring(10, directed = TRUE)
degree_balance(g_directed)
#> Out-degree stats:
#>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#>       1       1       1       1       1       1 
#> 
#> In-degree stats:
#>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#>       1       1       1       1       1       1 
#> Warning: the standard deviation is zero
#> 
#> Correlation between in and out degree: NA 
#> Mean out-degree: 1 
#> Mean in-degree: 1 
#> $out_degree
#>  [1] 1 1 1 1 1 1 1 1 1 1
#> 
#> $in_degree
#>  [1] 1 1 1 1 1 1 1 1 1 1
#> 

# Undirected graph example
g_undirected <- make_ring(10)
degree_balance(g_undirected)
#> Degree stats:
#>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#>       2       2       2       2       2       2 
#> $degree
#>  [1] 2 2 2 2 2 2 2 2 2 2
#> 
```
