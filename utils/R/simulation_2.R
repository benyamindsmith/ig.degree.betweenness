# Load the igraph package
library(igraph)
library(tidyverse)
library(ig.degree.betweenness)
# Set parameters
num_nodes <- 17     # Number of nodes (adjust as needed)
initial_edges <- 1   # Starting edges for preferential attachment

# Create a directed, scale-free network using the Barabási-Albert model
g <- sample_pa(n = num_nodes, m = initial_edges, directed = TRUE)

# Introduce additional edges to high-degree nodes to accentuate popularity differences
num_extra_edges <- 350   # Additional edges to create more popular nodes
set.seed(123)           # For reproducibility

for (i in 1:num_extra_edges) {
  # Sample nodes with probability proportional to their degree (to reinforce popularity)
  from <- sample(V(g), 1, prob = degree(g, mode = "in") + 1)  # +1 to avoid zero probabilities
  to <- sample(V(g), 1)

  # Ensure we don't add the same edge repeatedly unless intended, allowing self-loops
  g <- add_edges(g, c(from, to))
}

# Add self-loops to a subset of nodes
num_self_loops <- 5
for (i in 1:num_self_loops) {
  node <- sample(V(g), 1)
  g <- add_edges(g, c(node, node))
}

# Summary of the graph to confirm properties
cat("Is the graph scale-free? (approximation based on degree distribution)\n")
print(power.law.fit(degree(g, mode = "in")))

# Plot the graph
plot(g, vertex.size = 20, edge.arrow.size = 0.5, main = "Directed Scale-Free Network with Gradient Popularity and Self-Loops")


g_ <- ig.degree.betweenness::prep_unlabeled_graph(g)

ig.degree.betweenness::plot_simplified_edgeplot(g_,main="Simulated Data")


ig.degree.betweenness::plot_simplified_edgeplot(
g_,
ig.degree.betweenness::cluster_degree_betweenness(g_),
main ="Smith Pittman"
)

ig.degree.betweenness::plot_simplified_edgeplot(
  g_,
  igraph::cluster_edge_betweenness(g_),
  main = "Girvan Newman"
)

ig.degree.betweenness::plot_simplified_edgeplot(
  g_,
  igraph::cluster_louvain(g_|>igraph::as.undirected()),
  main = "Louvain"
)


#Degree-Distribution

# Recreate this graph
all_degree<- igraph::degree(g_) |>
  as.data.frame()|>
  tibble::rownames_to_column()|>
  dplyr::rename(degree=`igraph::degree(g_)` ,
                study=rowname)

in_degree <- igraph::degree(g_, mode = "in")|>
  as.data.frame()|>
  tibble::rownames_to_column()|>
  dplyr::rename(in_degree=`igraph::degree(g_, mode = "in")` ,
                study=rowname)

out_degree <- igraph::degree(g_, mode = "out") |>
  as.data.frame()|>
  tibble::rownames_to_column()|>
  dplyr::rename(out_degree=`igraph::degree(g_, mode = "out")` ,
                study=rowname)

degree_df <- merge(in_degree,
                   out_degree)|>
  merge(all_degree)|>
  dplyr::mutate(in_degree = -in_degree)|>
  tidyr::pivot_longer(cols = c(in_degree,out_degree))

ggplot(degree_df,
       mapping = aes(y =reorder(study, degree), x = -value, fill = name))+
  theme_minimal()+
  geom_col()+
  theme(axis.title.y = element_blank(),
        legend.title = element_blank(),
        legend.position = "bottom",
        axis.title.x = element_blank())+
  scale_fill_manual(labels = c("Referrals In", "Referrals Out"), values = scales::hue_pal()(2))+
  scale_x_continuous(labels = abs)
