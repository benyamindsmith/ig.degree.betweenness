library(tidyverse)
library(igraph)
library(igraphdata)
data("karate")

graph <- karate
community_list <- list()
community_list <- append(communities, clusters(graph)$membership)
closeness_nodes <- names(sort(-closeness(graph)))
communities <- list()
communities_list <- list()
subgraphs <- list()
n <-length(closeness_nodes)

for(i in 1:n){

  edgelist <- get.edgelist(graph, names=TRUE) |>
    apply(1, function(x) paste0(x, collapse="|"))

  subgraph <- subgraph.edges(graph=graph, eids=grep(closeness_nodes[i],edgelist), delete.vertices = TRUE)

  subgraphs[[i]]<- subgraph
  if(closeness_nodes[i] %in% get.edgelist(subgraph)[,1]){
    members <- get.edgelist(subgraph)[,2]
  }else{
    members <- get.edgelist(subgraph)[,1]
  }

  if(length(members)==0){
    break
  }

  communities[[i]]<- c(rep(i, length(c(closeness_nodes[i],members))))
  names(communities[[i]])<- c(closeness_nodes[i],members)
  for (member in communities[[i]]){
    graph <- graph-member
  }
}

m <- length(communities)
for(i in 1:m){
  graph_names<- names(V(karate))
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


modularities <- sapply(communities_list, function(x) modularity(karate,x))
iter_num <- which.max(modularities)

res <- list()
graph<- karate

res$names <- V(graph)$name
res$vcount <- vcount(graph)
res$algorithm <- "node closeness"
res$membership <- communities_list[[1]]
#res$merges <- igraph::merges(graph) + 1
#res$removed.edges <- res$removed.edges + 1
res$bridges <- igraph::bridges(graph) + 1
class(res) <- "communities"



plot(karate,
     main="True Graph")

plot(
  res,
  karate,
  main = "Node Closeness Clustering - 2 Groups, 5 Misclassifications"
)


plot(
  cluster_edge_betweenness(karate),
  karate,
  main = "Girvan Newman- Interpretation is Difficult"
)

