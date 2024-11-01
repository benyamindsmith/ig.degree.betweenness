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
affiliations:
  - name: "University of Toronto"
    index: 1
date: "2024-10-31"
bibliography: paper.bib
output:
  rticles::joss_article
  # md_document:
  #   preserve_yaml: TRUE
  #   variant: "markdown_strict"
journal: JOSS
---

# Summary

{ig.degree.betweenness} is an R [@base2022] package which implements the "Smith-Pittman" community detection algorithm [@sp_abstract] and is directly compatible with networks and sociograms constructed and loaded with `igraph` package [@igraph_software] by Csardi and Nepusz [@igraph_article]. {ig.degree.betweenness} also offers utility functions to which enable neater plotting of densely connected networks and preparation of unlabeled graphs for algorithm implementation.

# Statement of Need

The `igraph` package offers a suite of community detection algorithms, including Girvan-Newman [@Girvan_Newman_2002] and Louvain [@louvain_paper]. In densely connected complex networks it has been noted by [@sp_abstract] that 
# Minimal Example

## Zachary's Karate Club Network
<!--
The dataset commonly referred to as "Zachary's karate club network" by Zachary (1997) is a social network between members of a university club led by president John A. and karate instructor Mr. Hi (pseudonyms). At the beginning of the study there was an initial conflict between the club president, John A., and Mr. Hi over the price of karate lessons. As time passed, the entire club became divided over this issue. After a series of increasingly sharp factional confrontations over the price of lessons, the officers of the club, led by John A., fired Mr. Hi. The supporters of Mr. Hi retaliated by resigning and forming a new organization headed by Mr. Hi. Figure 1 shows the karate club network where the nodes signify individuals in the club and the edges signifies the existence of a relationship between two members. The node color indicates which group the members associated with post-split. 

Since the division of the club and its members is known, this social network is a classic example dataset used and studied. In the context of community detection, the object of interest is seeing if the split could be identified based on the relationships between members. When applied in an unsupervised setting, the Girvan-Newman and Louvain algorthims identify communities of nodes which optimize modularity according to their approaches. However, the communities identified do not appear to identify a possible division in the group which is contextually informative or interpretative. The Smith-Pittman algorithm identifies 3 communities which could can be understood as individuals who would certainly associate with John A. or Mr. Hi and an uncertain group. Figure 2 shows the comparison between the three algorithms. 


![The Zachary karate club network with the true split between members defined by node colors. John A. and Mr. Hi are denoted by 'J' and 'H', with other members being listed as numbers](paper_files/figure-latex/unnamed-chunk-1-1.pdf) 


![Unsupervised Community Detection by (a) Girvan-Newman, (b) Louvain and (c) Smith-Pittman for the karate network.](paper_files/figure-latex/unnamed-chunk-2-1.pdf) 
-->

# Acknowledgements

# References