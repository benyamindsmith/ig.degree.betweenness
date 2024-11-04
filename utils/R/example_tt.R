library(tidyverse)
library(tidygraph)
library(igraph)
library(ig.degree.betweenness)

monster_movie_genres <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2024/2024-10-29/monster_movie_genres.csv')


dummy_matrix<- monster_movie_genres |>
  dplyr::mutate(
    value=1
  )|>
  tidyr::pivot_wider(
    id_cols = tconst,
    names_from=genres,
    values_from = value,
    values_fill=0
  )|>
  dplyr::select(-tconst)|>
  as.matrix.data.frame()


genre_adj_matrix <-t(dummy_matrix) %*% dummy_matrix
# Setting self referrals to zero
diag(genre_adj_matrix) <- 0


movie_graph<- genre_adj_matrix|>
  as.data.frame()|>
  tibble::rownames_to_column()|>
  tidyr::pivot_longer(cols=Comedy:War)|>
  dplyr::rename(
    c(
      from=rowname,
      to = name
    )
  )|>
  dplyr::rowwise()|>
  dplyr::mutate(
    combo = paste0(sort(c(from, to)), collapse = ",")
  )|>
  dplyr::arrange(combo)|>
  dplyr::distinct(combo,.keep_all = TRUE)|>
  dplyr::select(-combo)|>
  tidyr::uncount(value)|>
  tidygraph::as_tbl_graph()


# Edge arrow size is small because graph is undirected and I want to keep the aesthetics (something to fix)

plot(
  movie_graph,
  edge.arrow.size=0.001,
  main = "Initial Network- Base Graphics"
)


ig.degree.betweenness::plot_simplified_edgeplot(
  movie_graph,
  edge.arrow.size=0.001,
  main = "Initial Network- Nicer Look (IMO)"
)


# Resize nodes based on degree

VS <- igraph::degree(movie_graph)*0.1

plot(
  movie_graph,
  edge.arrow.size=0.001,
  main = "Initial Network- Base Graphics",
  vertex.size=VS
)

ig.degree.betweenness::plot_simplified_edgeplot(
  movie_graph,
  main = "Main Network",
  vertex.size=VS,
  edge.arrow.size= 0.001
)

# Cluster Nodes

gn_cluster <- movie_graph|>
  igraph::as.undirected()|>
  igraph::cluster_edge_betweenness()

louvain_cluster <- movie_graph|>
  igraph::as.undirected()|>
  igraph::cluster_louvain()

sp_cluster <- movie_graph|>
  igraph::as.undirected()|>
  ig.degree.betweenness::cluster_degree_betweenness()


# Visualize

ig.degree.betweenness::plot_simplified_edgeplot(
  movie_graph,
  gn_cluster,
  main = "Girvan Newman",
  vertex.size=VS,
  edge.arrow.size=0.001
)

ig.degree.betweenness::plot_simplified_edgeplot(
  movie_graph,
  louvain_cluster,
  main = "Louvain",
  vertex.size=VS,
  edge.arrow.size=0.001
)

ig.degree.betweenness::plot_simplified_edgeplot(
  movie_graph,
  sp_cluster,
  main = "Smith-Pittman",
  vertex.size=VS,
  edge.arrow.size=0.001
)


# Degree Distribution- SP clustering follows a hierarchical clustering
all_degree<- igraph::degree(movie_graph) |>
  as.data.frame()|>
  tibble::rownames_to_column()|>
  dplyr::rename(degree=`igraph::degree(movie_graph)` ,
                study=rowname)

ggplot(all_degree,
       mapping = aes(y =reorder(study, degree), x = degree))+
  theme_minimal()+
  geom_col()+
  theme(axis.title.y = element_blank(),
        legend.title = element_blank(),
        legend.position = "bottom",
        axis.title.x = element_blank())
