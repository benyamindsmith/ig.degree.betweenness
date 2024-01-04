#' Prepared Unlabeled Graph to work with Degree Betweeness Algorithm
#'
#' @export

prep_unlabeled_graph <- function(graph){


  degree_nodes <- names(sort(degree(graph),decreasing = TRUE))

  if (is.null(degree_nodes)) {
    prepared_graph <- set_vertex_attr(graph_, "name", value = 1:vcount(graph_))

  } else{
    prepared_graph <- graph
  }
  return(prepared_graph)

}
