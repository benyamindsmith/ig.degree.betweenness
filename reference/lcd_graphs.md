# Generate Linearized Chord Diagram (LCD) Graphs

**\[experimental\]**

A family of functions to generate networks based on the Linearized Chord
Diagram (LCD) model using preferential attachment. The suite includes
the standard LCD model as well as variants that introduce bidirectional
edges, alternating direction attachment, and mixed degree preferences.

## Usage

``` r
lcd_graph(n, m = 1, directed = TRUE)

lcd_graph_bidirectional(n, m = 1, directed = TRUE, bidirectional_prob = 0.5)

lcd_graph_alternating(n, m = 1, directed = TRUE)

lcd_graph_mixed(n, m = 1, directed = TRUE, out_weight = 0.5)
```

## Arguments

- n:

  Integer. The total number of vertices (nodes) in the generated graph.

- m:

  Integer. The number of edges each new node adds during its time step.
  Defaults to 1.

- directed:

  Logical. Whether the generated graph should be directed. Defaults to
  `TRUE`.

- bidirectional_prob:

  Numeric. The probability (between 0 and 1) of adding a reverse edge
  (target -\> source) when generating bidirectional graphs. Used only in
  `lcd_graph_bidirectional`. Defaults to 0.5.

- out_weight:

  Numeric. The probability weight (between 0 and 1) given to the
  out-degree pool versus the in-degree pool. Used only in
  `lcd_graph_mixed`. Defaults to 0.5.

## Value

An `igraph` object representing the generated LCD graph.

## Details

The standard `lcd_graph` function builds a network step-by-step. At each
time step `t` from 1 to `n`, a new node is added and generates `m`
edges. The target of each edge is chosen preferentially based on the
degree of the existing nodes.

The package also provides three variations:

- `lcd_graph_bidirectional`: Adds a primary edge and, with a specified
  probability, simultaneously adds a reverse edge.

- `lcd_graph_alternating`: Alternates between using out-degree and
  in-degree pools for preferential attachment targets.

- `lcd_graph_mixed`: Chooses between out-degree and in-degree pools for
  attachment based on a weighted probability.

## References

Barabási, A.-L. (2016). *Network Science*. Cambridge University Press.
Chapter 5: The Barabási-Albert Model.
<https://networksciencebook.com/chapter/5>

## Examples

``` r
# Generate a standard directed LCD graph with 100 nodes and 2 edges per step
g1 <- lcd_graph(n = 100, m = 2)

# Generate a graph where reverse edges appear 30% of the time
g2 <- lcd_graph_bidirectional(n = 100, m = 1, bidirectional_prob = 0.3)

# Generate a graph alternating between in-degree and out-degree attachment
g3 <- lcd_graph_alternating(n = 100, m = 3)

# Generate a mixed graph favoring out-degree attachment 70% of the time
g4 <- lcd_graph_mixed(n = 100, m = 2, out_weight = 0.7)
```
