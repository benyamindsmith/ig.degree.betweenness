#' Monster Movie Genre Network
#'
#' Interaction between genres in "monster" titled movies from the \href{https://developer.imdb.com/non-commercial-datasets/}{Internet Movie Database}. From data released by the \href{https://github.com/rfordatascience/tidytuesday/tree/main/data/2024/2024-10-29}{TidyTuesday} project which has has been processed into a undirected graph. See \href{https://bensstats.wordpress.com/2024/11/11/smith-pittman-algorithm-enhancing-community-detection-in-networks/}{this blog} for information on how the graph was created.
#'
#' The original data consists of 630 movies spanning 22 genres. The network formed results in an directed network with 22 nodes (corresponding to movie genres) and 913 edges (corresponding to the ordered interactions between genres).
#'
#' @format A `igraph` object (e.g. representing "monster" titled movie genre relationships. The structure includes:
#' \describe{
#'   \item{nodes}{"Monster" titled movie genres}
#'   \item{edges}{The relationship between other genres.}
#' }
#' @source The Internet Movie Database; TidyTuesday
#' @name monster_movie_network
#' @docType data
#' @usage
#' monster_movie_network
NULL
