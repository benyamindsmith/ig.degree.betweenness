# Install and load igraph if you don't have it already
# install.packages("igraph")
library(igraph)

# Set a seed for reproducibility
set.seed(123)

# Number of nodes
num_nodes <- 200

# Generate a small-world network using the Watts-Strogatz model
# k: number of neighbors for each node
# p: rewiring probability
small_world_network <- sample_smallworld(dim = 1, size = num_nodes, nei = 3, p = 0.01)

# Generate a scale-free network using the Barabási-Albert model
scale_free_network <- sample_pa(num_nodes, m = 3, directed = FALSE)

# Analyze properties of the small-world network
cat("Small-World Network:\n")
cat("Average path length:", mean_distance(small_world_network), "\n")
cat("Clustering coefficient:", transitivity(small_world_network), "\n\n")

# Analyze properties of the scale-free network
cat("Scale-Free Network:\n")
cat("Average path length:", mean_distance(scale_free_network), "\n")
cat("Clustering coefficient:", transitivity(scale_free_network), "\n")

# Plot both networks
par(mfrow = c(1, 2))  # To plot side by side
plot(small_world_network, vertex.size=5, vertex.label=NA,
     edge.arrow.size=0.5, main="Small-World Network")

plot(scale_free_network, vertex.size=5, vertex.label=NA,
     edge.arrow.size=0.5, main="Scale-Free Network")


# Set a seed for reproducibility
set.seed(123)


par(mfrow = c(1, 2))  # To plot side by side
plot(
  small_world_network|>
    igraph::cluster_edge_betweenness(),
  small_world_network,
  vertex.size=5,
  vertex.label=NA,
  edge.arrow.size=0.5,
  main="Small-World Network- Girvan Newman")

plot(
  scale_free_network|>
    igraph::cluster_edge_betweenness()
    ,
  scale_free_network,
  vertex.size=5,
  vertex.label=NA,
  edge.arrow.size=0.5,
  main="Scale-Free Network- Girvan Newman"
  )


# Set a seed for reproducibility
set.seed(123)



par(mfrow = c(1, 2))  # To plot side by side
plot(
  small_world_network|>
    igraph::cluster_louvain(),
  small_world_network,
  vertex.size=5,
  vertex.label=NA,
  edge.arrow.size=0.5,
  main="Small-World Network- Louvain")

plot(
  scale_free_network|>
    igraph::cluster_louvain()
  ,
  scale_free_network,
  vertex.size=5,
  vertex.label=NA,
  edge.arrow.size=0.5,
  main="Scale-Free Network- Louvain"
)


# Set a seed for reproducibility
set.seed(123)


par(mfrow = c(1, 2))  # To plot side by side
plot(
  small_world_network|>
    ig.degree.betweenness::prep_unlabeled_graph()|>
    ig.degree.betweenness::cluster_degree_betweenness(),
  small_world_network|>
    ig.degree.betweenness::prep_unlabeled_graph(),
  vertex.size=5,
  vertex.label=NA,
  edge.arrow.size=0.5,
  main="Small-World Network- Smith Pittman")

plot(
  scale_free_network|>
    ig.degree.betweenness::prep_unlabeled_graph()|>
    ig.degree.betweenness::cluster_degree_betweenness()
  ,
  scale_free_network|>
    ig.degree.betweenness::prep_unlabeled_graph(),
  vertex.size=5,
  vertex.label=NA,
  edge.arrow.size=0.5,
  main="Scale-Free Network- Smith Pittman"
)
