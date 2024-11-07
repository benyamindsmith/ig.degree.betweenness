#' Prepared Unlabeled Graph to work with Degree-Betweenness Algorithm
#'
#' Presently, \code{cluster_degree_betweenness()} function only works with labeled graphs. \code{prep_unlabeled_graph()} is a utility function that gives an unlabeled graph labels which are string values of their vertices.
#'
#' @param graph an unlabeled graph.
#' @return An "igraph" object with named vertices.
#' @seealso [cluster_degree_betweenness()] which this function aids.
#' @export
#' @examples
#' library(igraph)
#' library(igraphdata)
#' library(ig.degree.betweenness)
#' data("UKfaculty")
#' # Making graph undirected so it looks nicer when its plotted
#' uk_faculty <- prep_unlabeled_graph(UKfaculty) |>
#'   as.undirected()
#'
#' ndb <- cluster_degree_betweenness(uk_faculty)
#'
#' plot(
#' ndb,
#' uk_faculty,
#' main= "Node Degree Clustering"
#' )
#'
#' ndb


prep_unlabeled_graph <- function(graph) {
  degree_nodes <- names(sort(degree(graph), decreasing = TRUE))

  if (is.null(degree_nodes)) {
    prepared_graph <-
      igraph::set_vertex_attr(graph, "name", value = 1:vcount(graph))

  } else {
    prepared_graph <- graph
  }
  return(prepared_graph)

}
