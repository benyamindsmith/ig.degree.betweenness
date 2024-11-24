library(igraph)
library(ggraph)
library(RColorBrewer)

# Set seed for reproducibility
set.seed(123)

# Create a graph with 16 nodes and 32 edges
g <- make_ring(16, directed = FALSE)
g <- add_edges(g, sample(1:vcount(g), 32, replace = TRUE))

# Assign random actor types
actor_types <- sample(0:3, vcount(g), replace = TRUE)
V(g)$actor_type <- actor_types

# Set edge weights based on "Policy A" measure
E(g)$policy_a <- runif(ecount(g))

# Plot the network with node colors based on actor type and edge widths based on edge weights
colors <- brewer.pal(4, "Set1")[actor_types + 1]
ggraph(g, layout = "circle") +
  geom_edge_link(aes(width = policy_a)) +
  geom_node_point(aes(color = colors), size = 10) +
  scale_color_manual(values = colors) +
  theme_void()

# Calculate the LTH redundancy measure
lth_redundancy_measure <- function(graph) {
  n <- vcount(graph)
  R <- matrix(0, n, n)

  for (i in 1:(n - 1)) {
    for (j in (i + 1):n) {
      # Get the actor types of the two nodes
      actor_type_i <- V(graph)$actor_type[i]
      actor_type_j <- V(graph)$actor_type[j]

      # Calculate the LTH redundancy measure based on actor types
      if (actor_type_i == 0 & actor_type_j == 0) {
        # Both are SIG A
        R[i, j] <- 1
        R[j, i] <- 1
      } else if (actor_type_i == 1 & actor_type_j == 1) {
        # Both are SIG B
        R[i, j] <- 1
        R[j, i] <- 1
      } else if (actor_type_i == 2 & actor_type_j == 2) {
        # Both are Political Party
        R[i, j] <- 1
        R[j, i] <- 1
      } else if (actor_type_i == 3 & actor_type_j == 3) {
        # Both are Politician
        R[i, j] <- 1
        R[j, i] <- 1
      }
    }
  }

  # Normalize the matrix
  R <- 2 / (n * (n - 1)) * R

  # Set diagonal values to zero
  diag(R) <- 0

  return(R)
}

# Calculate the LTH-based redundancy matrix
R_lth <- lth_redundancy_measure(g)

# Endogenize the LTH redundancy measure as "Policy Solidarity"
V(g)$policy_solidarity <- colSums(R_lth)

actor_legend <- c("Special Interest Group A", "Special Interest Group B", "Political Party", "Politician")

# Plot the network with node colors based on actor type and node size based on Policy Solidarity
ggraph(g, layout = "circle") +
  geom_edge_link(aes(width = policy_a)) +
  geom_node_point(aes(color = colors, size = policy_solidarity)) +
  scale_color_manual(values = colors, labels = actor_legend) +
  scale_size_continuous(range = c(5, 15), name = "Policy Solidarity") +
  theme_void() +
  theme(legend.position = "right", legend.direction = "vertical") +
  labs(title = "Policy A Network", subtitle = "Circle layout with node color based on actor type and node size based on Policy Solidarity")


# Convert the tidygraph object to a graph object
g <- as.undirected(g) |> ig.degree.betweenness::prep_unlabeled_graph()
VS <- igraph::degree(g)*3 # Sizing to make it look nice.

# Smith Pittman stuff
# Initial graph
ig.degree.betweenness::plot_simplified_edgeplot(
  g,
  vertex.size = VS,
  main = 'Policy "A" Network'
  )

# Community Detection Alogithms

# Girvan Newman - Edge Betweenness
communities_gn <- igraph::cluster_edge_betweenness(g)
# Louvain - Maximizes Modularity Directly
communities_louvain <- igraph::cluster_louvain(g)
# Smith - Pittman - Maximizes Modularity Directly
communities_sp <- ig.degree.betweenness::cluster_degree_betweenness(g)

# Initial graph
ig.degree.betweenness::plot_simplified_edgeplot(
  g,
  communities = communities_gn,
  vertex.size = VS,
  main = 'Girvan-Newman'
)

ig.degree.betweenness::plot_simplified_edgeplot(
  g,
  communities = communities_louvain,
  vertex.size = VS,
  main = 'Louvain'
)

ig.degree.betweenness::plot_simplified_edgeplot(
  g,
  communities = communities_sp,
  vertex.size = VS,
  main = 'Smith-Pittman'
)

# Better looking graph
set.seed(123)
plot(g,
     vertex.size = VS,
     main = 'Policy "A" Network')


set.seed(123)
plot(
     communities_gn,
     g,
     vertex.size = VS,
     main = 'Girvan-Newman')

set.seed(123)
plot(
  communities_louvain,
  g,
  vertex.size = VS,
  main = 'Louvain')


set.seed(123)
plot(
  communities_sp,
  g,
  vertex.size = VS,
  main = 'Smith-Pittman')

