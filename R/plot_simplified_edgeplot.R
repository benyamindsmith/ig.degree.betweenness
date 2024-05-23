#' Plot Simplified Edgeplot
#' This function generates a simplified edge plot of an igraph object, optionally highlighting communities if provided.
#'
#' @param graph igraph object
#' @param communities optional; A communities object
#' @examples
#' \dontrun{
#' # Create an igraph object
#' my_graph <- igraph::make_ring(10)
#' # Plot the simplified edge plot
#' plot_simplified_edgeplot(my_graph)
#' }
#'
#' @export

plot_simplified_edgeplot <- function(graph,
                                     communities = NULL,
                                     ...){
  if(class(graph)!="igraph"){
    stop('Error: "graph" argument needs to be of class "igraph"')
  }

  if(!is.null(communities)){
    if(class(communities)!="communities"){
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
