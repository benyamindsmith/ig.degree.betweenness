library(igraph)
library(ig.degree.betweenness)

# Creating the Network
oncology_network <- read.table("edgelist.txt", sep = "\t", header = FALSE, stringsAsFactors = FALSE) |>
  as.matrix()|>
  igraph::graph_from_edgelist(directed = TRUE)


# Testing it out
# Replicating the arXiv paper results.
sp_clusters <- ig.degree.betweenness::cluster_degree_betweenness(oncology_network)

ig.degree.betweenness::plot_simplified_edgeplot(oncology_network,sp_clusters)
