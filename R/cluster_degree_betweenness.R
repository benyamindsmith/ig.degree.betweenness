#' Community structure detection based on node degree centrality and edge betweeeness
#'
#'This algorithm detects communities by calculating the degree centrality measures of nodes and edge betweenness.
#'
#'This can be thought of as an alternative version of `igraph::cluster_edge_betweeness()`.
#'
#'The function iteratively removes edges based on their betweenness centrality and the degree of their adjacent nodes. At each iteration, it identifies the edge with the highest betweenness centrality among those connected to nodes with the highest degree.It then removes that edge and recalculates the modularity of the resulting graph. The process continues until all edges have been assessed or until no further subgraph can be created with the optimal number of communites being chosen based on maximization of modularity.
#'
#' @param graph The graph to analyze
#' @importFrom igraph clusters
#' @importFrom igraph degree
#' @importFrom igraph ecount
#' @importFrom igraph get.edgelist
#' @importFrom igraph bridges
#' @importFrom igraph subgraph.edges
#' @importFrom igraph V
#' @importFrom igraph modularity
#' @importFrom igraph vcount
#' @importFrom igraph E
#' @importFrom igraph edge_betweenness
#' @importFrom igraph delete_edges
#' @importFrom igraph components
#' @importFrom rlist list.append
#' @import igraphdata
#' @export
#' @examples
#' library(igraphdata)
#' data("karate")
#' ndb <- cluster_degree_betweenness(karate)
#' plot(
#' ndb,
#' karate,
#' main= "Degree-Betweenness Clustering"
#' )
#'
#' ndb
#'
#' # UNLABELED GRAPH EXAMPLE
#'
#' data("UKfaculty")
#' # Making graph undirected so it looks nicer when its plotted
#' uk_faculty <- prep_unlabeled_graph(UKfaculty) |>
#'   as.undirected()
#'
#' ndb <- cluster_degree_betweenness(uk_faculty)
#'
#' plot(
#'   ndb,
#'   uk_faculty,
#'   main= "Smith-Pittman Clustering for UK Faculty"
#' )
#'




cluster_degree_betweenness <- function(graph) {
  graph_ <- graph
  n_edges <- length(igraph::E(graph_))
  cmpnts <- list()

  for (i in 1:n_edges) {
    degree_nodes <- names(sort(igraph::degree(graph_), decreasing = TRUE))

    edgelist <- igraph::get.edgelist(graph_, names = TRUE) |>
      apply(1, function(x)
        paste0(x, collapse = "|"))

    edge_btwn <- igraph::edge_betweenness(graph_)
    names(edge_btwn) <- edgelist


    subgraph <-
      igraph::subgraph.edges(
        graph = graph_,
        eids = grep(degree_nodes[1], edgelist),
        delete.vertices = TRUE
      )

    if (length(E(subgraph)) == 0) {
      cmpnts <- rlist::list.append(cmpnts, components(graph_))

      next
    }

    subgraph_edgelist <- igraph::get.edgelist(subgraph, names = TRUE) |>
      apply(1, function(x)
        paste0(x, collapse = "|"))

    subgraph_edge_betweeness <-
      edge_btwn[names(edge_btwn) %in% subgraph_edgelist] |>
      sort(decreasing = TRUE) |>
      names()

    graph_ <- graph_ |>
      igraph::delete_edges(subgraph_edge_betweeness[1])

    cmpnts <- rlist::list.append(cmpnts, components(graph_))
  }


  graph_ <- graph
  communities <- lapply(cmpnts, function(x)
    x[["membership"]])
  modularities <-
    lapply(communities, function(x)
      igraph::modularity(graph_, x)) |>
    unlist()

  iter_num <- which.max(modularities)
  res <- list()


  res$names <- igraph::V(graph_)$name
  res$vcount <- igraph::vcount(graph_)
  res$algorithm <- "node degree+edge betweenness"
  res$modularity <- modularities
  res$membership <- communities[[iter_num]]
  res$bridges <- igraph::bridges(graph) + 1
  class(res) <- "communities"

  return(res)
}
