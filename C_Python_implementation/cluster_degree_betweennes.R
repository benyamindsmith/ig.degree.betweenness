library(igraph);
library(ig.degree.betweenness);

args <- commandArgs(TRUE)

# Read in edgelist like Python and C igraph
lines <- readLines(args[1])
#lines <- readLines("SNA_pres_edgelist.txt")
edges <- lapply(lines, function(line) unlist(strsplit(line, "\t")))
edge_matrix <- do.call(rbind, edges)
igraph_ex <- graph_from_edgelist(edge_matrix, directed=TRUE)


# Modified to print output, comment out message() and cat()
cluster_degree_betweenness <- function (graph)
{
  graph_ <- graph
  #graph_ <- igraph_ex
  igraph::V(graph_)$name <- paste("__", names(igraph::V(graph_)), "__", sep="") #this keeps output consistent to Python for numeric ids;
  names_order_orig <- igraph::V(graph_)$name
  n_edges <- length(igraph::E(graph_))
  n_nodes <- length(igraph::V(graph_))
  cmpnts <- list()
  modlars <- list()
  for (i in 1:(n_edges)) {
    degree_nodes <- names(sort(igraph::degree(graph_), decreasing = TRUE))
    edgelist <- apply(igraph::as_edgelist(graph_, names = TRUE),
                      1, function(x) paste0(x, collapse = "|"))
    edge_btwn <- igraph::edge_betweenness(graph_)
    names(edge_btwn) <- edgelist
    subgraph <- igraph::subgraph_from_edges(graph = graph_, eids = grep(degree_nodes[1],
                                                                        edgelist), delete.vertices = TRUE)
    if (length(E(subgraph)) == 0) {
      cmpnts <- rlist::list.append(cmpnts, components(graph_, mode="weak"))
      next
    }
    subgraph_edgelist <- apply(igraph::as_edgelist(subgraph,
                                                   names = TRUE), 1, function(x) paste0(x, collapse = "|"))
    subgraph_edge_betweeness <- names(sort(edge_btwn[names(edge_btwn) %in%
                                                       subgraph_edgelist], decreasing = TRUE))
    graph_ <- igraph::delete_edges(graph_, subgraph_edge_betweeness[1])
    cmpnts.tmp <- components(graph_, mode=c("weak"))
    cmpnts <- rlist::list.append(cmpnts, cmpnts.tmp)
    modularity <- igraph::modularity(graph, cmpnts.tmp$membership)
    modlars <- rlist::list.append(modlars, modularity)
    message(paste("Iteration ", i, ": modularity ", modularity, sep=""))
    #message(paste(i, sep=""))
  }
  graph_ <- graph
  communities <- lapply(cmpnts, function(x) x[["membership"]])
  modularities <- unlist(lapply(modlars, function(x) x))
  iter_num <- which.max(modularities)
  res <- list()
  res$names <- igraph::V(graph_)$name
  res$vcount <- igraph::vcount(graph_)
  res$algorithm <- "node degree+edge betweenness"
  res$modularity <- modularities
  res$membership <- communities[[iter_num]]
  res$bridges <- igraph::bridges(graph_)
  class(res) <- "communities"

  message(paste("Number of nodes: ", n_nodes, sep=""))
  message(paste("Number of edges: ", n_edges, sep=""))
  message(paste("Iteration with highest modularity: ", iter_num, sep=""))
  message(paste("Modularity for full graph with detected communities: ", max(res$modularity), sep=""))
  message(paste("Number of communities: ", length(unique(res$membership)), sep=""))

  message(paste("Assigned community for each node: ", sep=""))
  cat(as.vector(res$membership)-1, sep=", ")
  cat("\n")
  message(paste("Nodes: ", sep=""))
  cat(res$names, sep=", ")
  cat("\n")

  return(res)
}

igraph_ex_sp <- cluster_degree_betweenness(igraph_ex)
# #str(igraph_ex_sp)
# #igraph_ex_sp$modularity
# igraph_ex_sp$membership = paste('Group_', igraph_ex_sp$membership, sep='');
# clusters_igraph_ex_sp <- data.frame(igraph_ex_sp$names, igraph_ex_sp$membership);
# #unique(igraph_ex_sp$membership);
