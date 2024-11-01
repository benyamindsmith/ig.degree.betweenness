#' Plot Simplified Edgeplot
#'
#' This function generates a simplified edge plot of an igraph object, optionally highlighting communities if provided.
#'
#' This function is ideally for networks with a low number of nodes having varying numbers of connection and self loops. See the example for a better visual understanding.
#'
#' @param graph igraph object
#' @param communities optional; A communities object
#' @param ... other arguments to be passed to the \code{plot()} function
#' @examples
#'# Load the igraph package
#' library(igraph)
#' library(ig.degree.betweenness)
#' # Set parameters
#' num_nodes <- 15    # Number of nodes (adjust as needed)
#' initial_edges <- 1   # Starting edges for preferential attachment
#'
#' # Create a directed, scale-free network using the Barabási-Albert model
#' g <- sample_pa(n = num_nodes, m = initial_edges, directed = TRUE)
#'
#' # Introduce additional edges to high-degree nodes to accentuate popularity differences
#' num_extra_edges <- 350   # Additional edges to create more popular nodes
#' set.seed(123)           # For reproducibility
#'
#' for (i in 1:num_extra_edges) {
#'   # Sample nodes with probability proportional to their degree (to reinforce popularity)
#'   from <- sample(V(g), 1, prob = degree(g, mode = "in") + 1)  # +1 to avoid zero probabilities
#'   to <- sample(V(g), 1)
#'
#'   # Ensure we don't add the same edge repeatedly unless intended, allowing self-loops
#'   g <- add_edges(g, c(from, to))
#' }
#'
#' # Add self-loops to a subset of nodes
#' num_self_loops <- 5
#' for (i in 1:num_self_loops) {
#'   node <- sample(V(g), 1)
#'   g <- add_edges(g, c(node, node))
#' }
#'
#'
#' g_ <- ig.degree.betweenness::prep_unlabeled_graph(g)
#'
#' ig.degree.betweenness::plot_simplified_edgeplot(g_,main="Simulated Data")
#' @export

plot_simplified_edgeplot <- function(graph,
                                     communities = NULL,
                                     ...){
  if(!inherits(graph,"igraph")){
    stop('Error: "graph" argument needs to be of class "igraph"')
  }

  if(!is.null(communities)){
    if(!inherits(communities,"communities")){
      stop('Error: "communities" argument needs to be of class "communities"')
    }
  }


  e <- igraph::get.edgelist(graph, names = FALSE)

  l <-
    qgraph::qgraph.layout.fruchtermanreingold(
      e,
      vcount = vcount(graph),
      area = 8 * (vcount(graph) ^ 2),
      repulse.rad = (vcount(graph) ^ 2.1)
    )

  igraph::E(graph)$weight <- 1

  graph <-
    igraph::simplify(
      graph,
      remove.multiple = T,
      remove.loops = F,
      edge.attr.comb = c(weight = "sum", type = "ignore")
    )

  igraph::E(graph)$label <- E(graph)$weight

  igraph::E(graph)$weight <-
    BBmisc::normalize(
      E(graph)$weight,
      method = "range",
      range = c(1.0, 5.0),
      margin = 1L,
      on.constant = "quiet"
    )

  if(is.null(communities)){
    plot(
      graph,
      edge.label.color = "#801818",
      vertex.label.dist = 1.5,
      vertex.label.degree = pi / 2,
      edge.curved = TRUE,
      layout = l,
      edge.label = E(graph)$label,
      edge.label.cex = 0.8,
      edge.width = (E(graph)$weight),
      edge.arrow.size = 0.2,
      ...
    )
  } else{
    plot(
      communities,
      graph,
      edge.label.color = "#801818",
      vertex.label.dist = 1.5,
      vertex.label.degree = pi / 2,
      edge.curved = TRUE,
      layout = l,
      edge.label = E(graph)$label,
      edge.label.cex = 0.8,
      edge.width = (E(graph)$weight),
      edge.arrow.size = 0.2,
      ...
    )
  }



}
