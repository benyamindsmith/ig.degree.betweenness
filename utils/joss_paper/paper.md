---
title: 'ig.degree.betweenness: A Community Detection Algorithm Leveraging Degree Centrality'
author: "Benjamin Smith"
tags:
  - R
  - igraph
  - community detection algorithms
  - visualization
authors:
  - name: Benjamin Smith
    orcid: 0009-0007-2206-0177
    affiliation: 1
  - name: Tyler Pittman
    orchid: 0000-0002-5013-6980
    affilation: 2
  - name: Wei Xu
    orchid: 0000-0002-0257-8856
    affiliation: [1,2]
affiliations:
  - name: "University of Toronto"
    index: 1
  - name: "UHN's Princess Margaret Cancer Centre"
    index: 2
date: "2024-11-05"
bibliography: paper.bib
output:
  rticles::joss_article
  # md_document:
  #   preserve_yaml: TRUE
  #   variant: "markdown_strict"
journal: JOSS

---



# Summary

{ig.degree.betweenness} is an R package which allows users to implement the "Smith-Pittman" community detection algorithm on networks and sociograms constructed and/or loaded with the {igraph} package. {ig.degree.betweenness} also offers utility functions which enable neater plotting of densely connected networks with high number of edges and a low number of nodes and the relevant preparation of unlabeled graphs for the Smith-Pittman algorithm's present implementation in the R programming language. There presently do not exist other implementations of this algorithm which are ready to use which are compatible in the {igraph} ecosystem. As a result, this contribution is welcome by {igraph} users interested in exploring and applying the Smith-Pittman algorithm in SNA settings.

# Statement of Need

{igraph} [@igraph_article] offers a suite functions and tools for interacting with graph data and engaging in social network analysis (SNA). A major area of study in SNA is the identification node clusters through methods referred to as "community detection algorithms" [@rostami2023community]. {igraph} allows users to employ a variety of popular community detection algorithms, including Girvan-Newman^[https://r.igraph.org/reference/cluster_edge_betweenness.html] [@Girvan_Newman_2002], Louvain^[https://r.igraph.org/reference/cluster_louvain.html] [@louvain_paper] and others^[For the full list of available community detection algorithms in the {igraph} R package, see the {igraph} reference manual: https://r.igraph.org/reference/index.html#community-detection]. In densely connected complex networks it has been noted by Smith, Pittman and Xu [@sp_paper] that considering the number of connections possessed by each individual node in a given network (degree centrality) along with edge-betweeness (as done by [@Girvan_Newman_2002]) offers an approach for identifying clusters which are more descriptive in certain settings. {ig.degree.betweenness} is an R package that contains a ready-to-use implementation of the Smith-Pittman community detection algorithm. 

# The Smith-Pittman Algorithm

The "Smith-Pittman" algorithm is a variation of the Girvan-Newman algorithm which first considers degree centrality (i.e., the number of connections possessed by each node in a given network) at the beginning of each iteration before examining the network edges' betweenness (i.e., the frequency with which an edge lies on the shortest paths between pairs of nodes, indicating its role in connecting different parts of the network).

The steps for the algorithm are: 

1. Identify the node with the highest degree-centrality in the network. 

2. Select the subgraph of the node with the highest degree centrality. Remove the edge possessing the highest calculated in the subgraph.

3. Recalculate the degree centrality for all nodes in the network and the betweenness for the remaining edge in the network,

4. Repeat from step 2. 

Conceptually, this algorithm (similar to Girvan-Newman and Louvain) can be specified to terminate once a pre-determined number of communities has been identified (based on the remaining connected nodes). However, the intention for using this algorithm is meant to be used in an unsupervised, modularity maximizing setting, where the grouping of nodes is decided on the strength of the connected clusters -a.k.a. modularity^[For a more formal definition of modularity, see: https://en.wikipedia.org/wiki/Modularity_(networks)]. Figure 1 provides a detailed overview of how the algorithm works.

![A detailed overview of how the Smith-Pittman Algorithm works](./images/sp_viz2.png)


# Minimal Examples

## Zachary's Karate Club Network

The dataset commonly referred to as "Zachary's karate club network" [@zachary1977information] is a social network between members of a university club led by president John A. and karate instructor Mr. Hi (pseudonyms). At the beginning of the study there was an initial conflict between the club president, John A., and Mr. Hi over the price of karate lessons. As time passed, the entire club became divided over this issue. After a series of increasingly sharp factional confrontations over the price of lessons, the officers of the club, led by John A., fired Mr. Hi. The supporters of Mr. Hi retaliated by resigning and forming a new organization headed by Mr. Hi. Figure 2 shows the karate club network where the nodes signify individuals in the club and the edges signifies the existence of a relationship between two members. The node color indicates which group the members associated with post-split. 

Since the division of the club and its members is known, this social network is a classic example dataset used and studied. In the context of community detection, the object of interest is seeing if the split could be identified based on the relationships between members. When applied in an unsupervised setting, the Girvan-Newman and Louvain algorthims identify communities of nodes which optimize modularity according to their approaches. However, the communities identified do not appear to identify a possible division in the group which is contextually informative or interpretative. The Smith-Pittman algorithm identifies 3 communities which could can be understood as individuals who would certainly associate with John A. or Mr. Hi and an uncertain group. Figure 3 shows the comparison between the three algorithms. 

![The Zachary karate club network with the true split between members defined by node colors. John A. and Mr. Hi are denoted by 'J' and 'H', with other members being listed as numbers](./images/karate_network.png){width=60%}

![Unsupervised Community Detection by (a) Girvan-Newman, (b) Louvain and (c) Smith-Pittman for the karate network.](./images/algorithm_comparison_karate.png)

## TidyTuesday - "Monster Movies" Dataset

<!---
Up to here to write
---->
The first visual is the constructed network. The other visuals are clusters based on the Girvan Newman (Edge Betweenness), Louvain (Direct Modularity Maximization) and Smith(thats me!)-Pittman (Node Degree + Edge Betweenness).

Girvan Newman doesn't tell any story (clustering everything in one group isn't much of a story). Louvain might be telling us something in terms of strength of clustering but doesn't necessarily speak about the reality of "monster" movie genre interactions. Smith-Pittman clustering tells the best story (albeit biased) with popular genres forming the primary working group followed by more ambivalent smaller subgroups and outlier nodes. 

This aligns with the degree (popularity) distribution (the bar graph) of the nodes as well (which is what our working paper asserts as well for certain contexts).

![Monster Movie genre network. Node size corresponds to the node degree and edge thickness and numbers corespond the number of connections shared between generes from the dataset.](paper_files/figure-latex/unnamed-chunk-2-1.pdf) 

![Girvan-Newman communities. Unable to identify any communities.](paper_files/figure-latex/unnamed-chunk-3-1.pdf) 

![Louvain communities. Communities identified, but do not provide descriptive value.](paper_files/figure-latex/unnamed-chunk-4-1.pdf) 

![Smith-Pittman communities. Communities identified provide descriptive value based on popular genres followed by a less popular genres, followed by isolated genres with litte to no interaction with other genres in the network.](paper_files/figure-latex/unnamed-chunk-5-1.pdf) 

## Other Utility Functions


### Preparing Unlabeled Graphs


```r
# Set parameters
# Number of nodes (adjust as needed)
num_nodes <- 15   
# Starting edges for preferential attachment
initial_edges <- 1

# Create a directed, scale-free network using the Barabási-Albert model
g <- igraph::sample_pa(n = num_nodes, m = initial_edges, directed = TRUE)

# Introduce additional edges to high-degree nodes to accentuate popularity differences
num_extra_edges <- 350   # Additional edges to create more popular nodes
set.seed(123)           # For reproducibility

for (i in 1:num_extra_edges) {
  # Sample nodes with probability proportional to their degree (to reinforce popularity)
  from <- sample( igraph::V(g), 1, prob =  igraph::degree(g, mode = "in") + 1)  # +1 to avoid zero probabilities
  to <- sample( igraph::V(g), 1)

  # Ensure we don't add the same edge repeatedly unless intended, allowing self-loops
  g <-  igraph::add_edges(g, c(from, to))
}

# Add self-loops to a subset of nodes
num_self_loops <- 5
for (i in 1:num_self_loops) {
  node <- sample( igraph::V(g), 1)
  g <-  igraph::add_edges(g, c(node, node))
}

g
```

```
## IGRAPH 36ae407 D--- 15 369 -- Barabasi graph
## + attr: name (g/c), power (g/n), m (g/n), zero.appeal (g/n), algorithm
## | (g/c)
## + edges from 36ae407:
##  [1]  2-> 1  3-> 2  4-> 1  5-> 1  6-> 1  7-> 1  8-> 6  9-> 3 10-> 7 11-> 7
## [11] 12-> 1 13-> 7 14-> 1 15-> 1  1->15  7->14  8->10  3-> 6  3-> 5  8->14
## [21] 10-> 9  1->11  7-> 5  7->11  2->12 15-> 9 14-> 3 11->10  7->10  8->14
## [31]  9-> 4  1-> 1  6-> 7 10->12  1->10 10-> 7  1-> 9 14-> 7 15->12 12-> 7
## [41]  1->11  7-> 6 11-> 2 10-> 5  1->12  7->13 10-> 1  3->11 10-> 6 14->15
## [51]  1->15  7->12 14-> 4  7-> 6  6-> 8  1-> 6  8->15  4-> 1  1-> 2  6-> 2
## [61]  6->13  5-> 6 10-> 3  2-> 4 15-> 9 15->14  4-> 7 12-> 8 13->14  1->15
## + ... omitted several edges
```


```r
igraph::vertex.attributes(g)$name
```

```
## NULL
```



```r
g_ <- ig.degree.betweenness::prep_unlabeled_graph(g)

igraph::vertex.attributes(g_)$name
```

```
##  [1]  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15
```


### Plotting Simplified Edgeplots



```r
 par(mar=c(0,0,0,0)+.1)

plot(
  g_,
  edge.arrow.size = 0.2,
  main = "Default Network"
  )
```

![](paper_files/figure-latex/unnamed-chunk-7-1.pdf)<!-- --> 



```r
 par(mar=c(0,0,0,0)+.1)


ig.degree.betweenness::plot_simplified_edgeplot(
  g_,
  edge.arrow.size = 0.2,
  main = "Simplified Network"
  )
```

![](paper_files/figure-latex/unnamed-chunk-8-1.pdf)<!-- --> 


```r
par(mar=c(0,0,0,0)+.1)

sp_communities <- ig.degree.betweenness::cluster_degree_betweenness(g_)

plot(sp_communities,
     g_,
     edge.arrow.size = 0.2,
     main = "Default Network")
```

![](paper_files/figure-latex/unnamed-chunk-9-1.pdf)<!-- --> 

```r
ig.degree.betweenness::plot_simplified_edgeplot(
  g_, 
  communities = sp_communities, 
  main = "Simplified Network")
```

![](paper_files/figure-latex/unnamed-chunk-9-2.pdf)<!-- --> 


# References
