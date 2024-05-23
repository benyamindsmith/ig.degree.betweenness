#' Community structure detection based on node degree centrality
#'
#'This algorithm detects communities by calculating the degree centrality measures of nodes and assigns communities based on the subsequent subgraphs. The steps outlined are the same as those outlined in `cluster_node_closeness()` with degree centrality being used instead of closeness.
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
#' @import igraphdata
#'
#' @examples
#' library(igraphdata)
#' data("karate")
#' nd <- cluster_node_degree(karate)
#' plot(
#' nd,
#' karate,
#' main= "Node Degree Clustering"
#' )
#'
#' nd

cluster_node_degree <- function(
    graph
) {
  warning("The following is a artifact of the research process.
          For the novel algorithm, please see cluster_degree_betweenness()")
  graph_ <- graph
  communities <- list()
  community_list <- list()
  community_list <- append(communities, clusters(graph_)$membership)
  degree_nodes <- names(sort(degree(graph_),decreasing = TRUE))
  communities_list <- list()
  subgraphs <- list()
  n <-length(degree_nodes)

  for (i in 1:n) {
    edgelist <- get.edgelist(graph_, names = TRUE) |>
      apply(1, function(x)
        paste0(x, collapse = "|"))

    subgraph <-
      subgraph.edges(
        graph = graph_,
        eids = grep(degree_nodes[i], edgelist),
        delete.vertices = TRUE
      )

    subgraphs[[i]] <- subgraph
    if (degree_nodes[i] %in% get.edgelist(subgraph)[, 1]) {
      members <- get.edgelist(subgraph)[, 2]
    } else{
      members <- get.edgelist(subgraph)[, 1]
    }

    if (length(members) == 0) {
      break
    }

    communities[[i]] <-
      c(rep(i, length(c(
        degree_nodes[i], members
      ))))
    names(communities[[i]]) <- c(degree_nodes[i], members)
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
  res$modularity <- modularities
  res$membership <- communities_list[[iter_num]]
  res$bridges <- bridges(graph) + 1
  class(res) <- "communities"
  return(res)

}
