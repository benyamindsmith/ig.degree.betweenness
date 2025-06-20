# Install relevant libraries
# pkgs <- c("dplyr","tibble","tidyr","tidygraph",
#           "igraph","ig.degree.betweenness")
# install.packages(pkgs)
# Load data
tuesdata <- tidytuesdayR::tt_load(2024, week = 44)
monster_movie_genres <- tuesdata$monster_movie_genres

# Prepare data for adjacency matrix
dummy_matrix <- monster_movie_genres |>
  dplyr::mutate(value = 1) |>
  tidyr::pivot_wider(
    id_cols = tconst,
    names_from = genres,
    values_from = value,
    values_fill = 0
  ) |>
  dplyr::select(-tconst) |>
  as.matrix.data.frame()

# Construct adjacency matrix
genre_adj_matrix <- t(dummy_matrix) %*% dummy_matrix
# Setting self loops to zero
diag(genre_adj_matrix) <- 0

# Construct the graph
monster_movie_network <- genre_adj_matrix |>
  as.data.frame() |>
  tibble::rownames_to_column() |>
  tidyr::pivot_longer(cols = Comedy:War) |>
  dplyr::rename(c(from = rowname, to = name)) |>
  dplyr::rowwise() |>
  dplyr::mutate(combo = paste0(sort(c(from, to)), collapse = ",")) |>
  dplyr::arrange(combo) |>
  dplyr::distinct(combo, .keep_all = TRUE) |>
  dplyr::select(-combo) |>
  tidyr::uncount(value) |>
  tidygraph::as_tbl_graph() |>
  as.igraph()

# Resize nodes based on node degree

VS <- igraph::degree(monster_movie_network) * 0.1

ig.degree.betweenness::plot_simplified_edgeplot(
  monster_movie_network,
  vertex.size = VS,
  edge.arrow.size = 0.001
)


save(monster_movie_network, file = "monster_movie_network.rda")
