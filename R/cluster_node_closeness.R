#' Community structure detection based on node closeness centrality
#'
#' This algorithm detects communities by calculating the closeness centrality measures of nodes and assigns communities based on the subsequent subgraphs. For more information see Details.
#'
#' The algorithm first calculates closeness centrality for all nodes in the graph and then starts from the node with the largest closeness centrality extracts the sub-graph set it as its "cluster". The remaining nodes are assigned to a separate cluster. This is preformed iteratively until all possible communities are identified.
#'
#'In the case of an overlap of nodes, the node with higher closeness centrality gets it. As a result, there are is no overlap in nodes between clusters. For choice of number of communities, the number which maximizes modularity is chosen.
#'
#'
#' @param graph The graph to analyze
#' @importFrom igraph clusters
#' @importFrom igraph closeness
#' @importFrom igraph ecount
#' @importFrom igraph get.edgelist
#' @importFrom igraph bridges
#' @importFrom igraph subgraph.edges
#' @importFrom igraph V
#' @importFrom igraph modularity
#' @importFrom igraph vcount
#' @import igraphdata
#' @export
#' @examples
#' library(igraphdata)
#' data("karate")
#' nc <- cluster_node_closeness(karate)
#' plot(
#' nc,
#' karate,
#' main= "Node Closeness Clustering"
#' )
#'
#' nc

cluster_node_closeness <- function(
    graph
) {

  graph_ <- graph
  communities <- list()
  community_list <- list()
  community_list <- append(communities, clusters(graph_)$membership)
  closeness_nodes <- names(sort(-closeness(graph_)))
  communities_list <- list()
  subgraphs <- list()
  n <-length(closeness_nodes)

  for (i in 1:n) {
    edgelist <- get.edgelist(graph_, names = TRUE) |>
      apply(1, function(x)
        paste0(x, collapse = "|"))

    subgraph <-
      subgraph.edges(
        graph = graph_,
        eids = grep(closeness_nodes[i], edgelist),
        delete.vertices = TRUE
      )

    subgraphs[[i]] <- subgraph
    if (closeness_nodes[i] %in% get.edgelist(subgraph)[, 1]) {
      members <- get.edgelist(subgraph)[, 2]
    } else{
      members <- get.edgelist(subgraph)[, 1]
    }

    if (length(members) == 0) {
      break
    }

    communities[[i]] <-
      c(rep(i, length(c(
        closeness_nodes[i], members
      ))))
    names(communities[[i]]) <- c(closeness_nodes[i], members)
    for (member in communities[[i]]) {
      graph_ <- graph_ - member
    }
  }


  graph_ <- graph

  for(i in 1:length(communities)){
    graph_names<- names(V(graph_))
    cumulative_communities <- unlist(communities[1:i])
    cumulative_communities_deduplicated <- cumulative_communities |>
      split(names(cumulative_communities)) |>
      lapply(function(x) sort(x)[1])|>
      unname()|>
      unlist()

    leftovers <-  graph_names[!(graph_names %in% names(cumulative_communities_deduplicated))]
    others <- rep(i+1,length(leftovers))
    names(others)<- leftovers

    communities_list[[i]]<- c(cumulative_communities_deduplicated,
                              others)
  }


  modularities <- sapply(communities_list, function(x) modularity(graph_,x))
  iter_num <- which.max(modularities)
  res <- list()


  res$names <- V(graph)$name
  res$vcount <- vcount(graph)
  res$algorithm <- "node closeness"
  res$membership <- communities_list[[iter_num]]
  res$bridges <- bridges(graph) + 1
  class(res) <- "communities"

  return(res)

}
