#' Prepared Unlabeled Graph to work with Degree-Betweenness Algorithm
#'
#'
#' @export
#' @examples
#' library(igraphdata)
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


prep_unlabeled_graph <- function(graph){


  degree_nodes <- names(sort(degree(graph),decreasing = TRUE))

  if (is.null(degree_nodes)) {
    prepared_graph <- set_vertex_attr(graph, "name", value = 1:vcount(graph))

  } else{
    prepared_graph <- graph
  }
  return(prepared_graph)

}
