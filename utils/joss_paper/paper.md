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
  - name: "Princess Margaret Cancer Centre: Toronto, Ontario, CA"
    index: 2
date: "2024-11-01"
bibliography: paper.bib
output:
  # rticles::joss_article
  md_document:
    preserve_yaml: TRUE
    variant: "markdown_strict"
journal: JOSS
---

# Summary

{ig.degree.betweenness} is an R (R Core Team 2022) package which
implements the “Smith-Pittman” community detection algorithm (Smith,
Pittman, and Xu 2024) and is directly compatible with networks and
sociograms constructed and loaded with `igraph` package (Csárdi et al.
2024) by Csardi and Nepusz (Csardi and Nepusz 2006).
{ig.degree.betweenness} also offers utility functions to which enable
neater plotting of densely connected networks with high number of edges
and a low number of nodes and preparation of unlabeled graphs for
algorithm implementation.

# Statement of Need

The `igraph` package offers a suite of community detection algorithms,
including Girvan-Newman (Girvan and Newman 2002) and Louvain (Blondel et
al. 2008). In densely connected complex networks it has been noted by
(Smith, Pittman, and Xu 2024) that

# Minimal Example

## Zachary’s Karate Club Network

The dataset commonly referred to as “Zachary’s karate club network” by
Zachary (1997) is a social network between members of a university club
led by president John A. and karate instructor Mr. Hi (pseudonyms). At
the beginning of the study there was an initial conflict between the
club president, John A., and Mr. Hi over the price of karate lessons. As
time passed, the entire club became divided over this issue. After a
series of increasingly sharp factional confrontations over the price of
lessons, the officers of the club, led by John A., fired Mr. Hi. The
supporters of Mr. Hi retaliated by resigning and forming a new
organization headed by Mr. Hi. Figure 1 shows the karate club network
where the nodes signify individuals in the club and the edges signifies
the existence of a relationship between two members. The node color
indicates which group the members associated with post-split.

Since the division of the club and its members is known, this social
network is a classic example dataset used and studied. In the context of
community detection, the object of interest is seeing if the split could
be identified based on the relationships between members. When applied
in an unsupervised setting, the Girvan-Newman and Louvain algorthims
identify communities of nodes which optimize modularity according to
their approaches. However, the communities identified do not appear to
identify a possible division in the group which is contextually
informative or interpretative. The Smith-Pittman algorithm identifies 3
communities which could can be understood as individuals who would
certainly associate with John A. or Mr. Hi and an uncertain group.
Figure 2 shows the comparison between the three algorithms.

    # Install packages
    # install.packages(c("igraph","igraphdata", "ig.degree.betweenness"))

    set.seed(5250) #Setting seed to visual reproducibility
    library(igraph)
    library(igraphdata)
    library(ig.degree.betweenness)

    data("karate")

    par(mar=c(0,0,0,0)+.1)
    plot(karate)

<figure>
<img src="./images/karate_network.png"
alt="The Zachary karate club network with the true split between members defined by node colors. John A. and Mr. Hi are denoted by ‘J’ and ‘H’, with other members being listed as numbers" />
<figcaption aria-hidden="true">The Zachary karate club network with the
true split between members defined by node colors. John A. and Mr. Hi
are denoted by ‘J’ and ‘H’, with other members being listed as
numbers</figcaption>
</figure>

    gn_karate <- karate |>
      igraph::cluster_edge_betweenness()

    louvain_karate <- karate |>
      igraph::cluster_louvain()

    sp_karate <- karate |>
      ig.degree.betweenness::cluster_degree_betweenness()

    par(mfrow= c(1,3),mar=c(0,0,0,0)+1)

    plot(
      gn_karate,
      karate,
      main = "(a)"
      )

    plot(
      louvain_karate,
      karate,
      main = "(b)"
    )

    plot(
      sp_karate,
      karate,
      main = "(c)"
    )

<figure>
<img src="./images/algorithm_comparison_karate.png"
alt="Unsupervised Community Detection by (a) Girvan-Newman, (b) Louvain and (c) Smith-Pittman for the karate network." />
<figcaption aria-hidden="true">Unsupervised Community Detection by (a)
Girvan-Newman, (b) Louvain and (c) Smith-Pittman for the karate
network.</figcaption>
</figure>

## Other Utility Functions

### Preparing Unlabeled Graphs

    # Set parameters
    num_nodes <- 15    # Number of nodes (adjust as needed)
    initial_edges <- 1   # Starting edges for preferential attachment

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

    ## IGRAPH b0008d6 D--- 15 369 -- Barabasi graph
    ## + attr: name (g/c), power (g/n), m (g/n), zero.appeal (g/n), algorithm
    ## | (g/c)
    ## + edges from b0008d6:
    ##  [1]  2-> 1  3-> 1  4-> 3  5-> 2  6-> 5  7-> 3  8-> 4  9-> 4 10-> 2 11-> 5
    ## [11] 12-> 1 13-> 2 14-> 4 15-> 2  4->15  1->14  9->10  3-> 6  5-> 5  9->14
    ## [21]  6-> 9  2->11  1-> 5  1->11  9->12  3-> 9  9-> 3 11->10  3->10 13->14
    ## [31] 11-> 4  5-> 1  9-> 7  2->12  2->10  5-> 7  2-> 9  5-> 7 11->12  2-> 7
    ## [41]  4->11  1-> 6 11-> 2 10-> 5  5->12  7->13 10-> 1  9->11 10-> 6  7->15
    ## [51]  5->15  2->12  7-> 4  1-> 6  4-> 8 12-> 6  8->15  3-> 1 12-> 2  5-> 2
    ## [61]  5->13 14-> 6  4-> 3  3-> 4  5-> 9 12->14 14-> 7  7-> 8 13->14  2->15
    ## + ... omitted several edges

    igraph::vertex.attributes(g)$name

    ## NULL

    g_ <- ig.degree.betweenness::prep_unlabeled_graph(g)

    igraph::vertex.attributes(g_)$name

    ##  [1]  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15

### Plotting Simplified Edgeplots

    plot(
      g_,
      edge.arrow.size = 0.2,
      main = "Default Network"
      )

![](paper_files/figure-markdown_strict/unnamed-chunk-2-1.png)

    ig.degree.betweenness::plot_simplified_edgeplot(
      g_,
      edge.arrow.size = 0.2,
      main = "Simplified Network"
      )

![](paper_files/figure-markdown_strict/unnamed-chunk-3-1.png)

    par(mfrow = c(1, 2))

    sp_communities <- ig.degree.betweenness::cluster_degree_betweenness(g_)

    plot(sp_communities,
         g_,
         edge.arrow.size = 0.2,
         main = "Default Network")

    ig.degree.betweenness::plot_simplified_edgeplot(
      g_, 
      communities = sp_communities, 
      main = "Simplified Network")

![](paper_files/figure-markdown_strict/unnamed-chunk-4-1.png)

# Acknowledgements

# References

Blondel, Vincent D, Jean-Loup Guillaume, Renaud Lambiotte, and Etienne
Lefebvre. 2008. “Fast Unfolding of Communities in Large Networks.”
*Journal of Statistical Mechanics Theory and Experiment* 2008 (10):
P10008. <https://doi.org/10.1088/1742-5468/2008/10/p10008>.

Csardi, Gabor, and Tamas Nepusz. 2006. “The Igraph Software Package for
Complex Network Research.” *InterJournal* Complex Systems: 1695.
<https://igraph.org>.

Csárdi, Gábor, Tamás Nepusz, Vincent Traag, Szabolcs Horvát, Fabio
Zanini, Daniel Noom, and Kirill Müller. 2024.
*<span class="nocase">igraph</span>: Network Analysis and Visualization
in r*. <https://doi.org/10.5281/zenodo.7682609>.

Girvan, M., and M. E. J. Newman. 2002. “Community Structure in Social
and Biological Networks.” *Proceedings of the National Academy of
Sciences* 99 (12): 7821–26. <https://doi.org/10.1073/pnas.122653799>.

R Core Team. 2022. *R: A Language and Environment for Statistical
Computing*. Vienna, Austria: R Foundation for Statistical Computing.
<https://www.R-project.org/>.

Smith, Benjamin, Tyler Pittman, and Wei Xu. 2024. “Centrality in
Collaboration: Community Detection for Oncology Researchers.”
*University of Toronto Journal of Public Health* TODO.
<https://arxiv.org>.
