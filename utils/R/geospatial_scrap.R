library(sfdep)
library(spdep)
library(ggplot2)

# define neighbors
nb <- st_contiguity(guerry$geometry)

# label the graph
g <- igraph::graph_from_adj_list(nb) |>
  ig.degree.betweenness::prep_unlabeled_graph()


sp <- ig.degree.betweenness::cluster_degree_betweenness(g)

VS <- igraph::degree(g)

plot(sp,
     g,
     vertex.size=VS)
library(igraphdata)
data("karate")

sp <- ig.degree.betweenness::cluster_degree_betweenness(karate)

VS <- igraph::degree(karate)

plot(sp,
     karate,
     vertex.size=VS)

# pull out clusters
clusters <- unname(sp$membership)

library(stplanr)
if (requireNamespace("igraph", quietly = TRUE)) {
  rnet <- rnet_breakup_vertices(stplanr::osm_net_example)
  rnet$louvain <-rnet_group(rnet,cluster_fun = igraph::cluster_louvain)
  rnet$sp <- rnet_group(rnet,cluster_fun =function(x)
    x |>
      ig.degree.betweenness::prep_unlabeled_graph()|>
      ig.degree.betweenness::cluster_degree_betweenness())
  plot(rnet["sp"])
  plot(rnet["louvain"])
}
