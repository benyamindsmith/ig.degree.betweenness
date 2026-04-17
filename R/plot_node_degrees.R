#' Visualize Node Degree Distribution in a Network Graph
#'
#' Generates a horizontal bar‐style plot of node degrees for an `igraph` network.
#' For undirected graphs, it shows each node’s total degree.
#' For directed graphs, it displays in‐degrees (as negative bars) alongside out‐degrees.
#'
#' @param graph An `igraph` object. Can be either directed or undirected.
#'
#' @return A `ggplot` object:
#' \itemize{
#'   \item **Undirected graphs:** A bar for each node showing its total degree.
#'   \item **Directed graphs:** Split bars per node with negative values for in‐degree
#'         (pointing left) and positive values for out‐degree (pointing right).
#' }
#'
#' @details
#' This function computes:
#' \describe{
#'   \item{Total degree}{Number of edges incident on each node (for undirected graphs).}
#'   \item{In‐degree}{Number of incoming edges per node (for directed graphs).}
#'   \item{Out‐degree}{Number of outgoing edges per node (for directed graphs).}
#' }
#' For directed graphs, in‐degrees are negated so that bars extend leftward,
#' providing an immediate visual comparison to out‐degrees.
#'
#' Internally, it uses:
#' \itemize{
#'   \item `igraph::degree()` to compute degrees,
#'   \item `dplyr` and `tidyr` for reshaping the data,
#'   \item `ggplot2` for plotting.
#' }
#'
#' @section Customization:
#' You can modify the returned `ggplot` with additional layers, themes, or labels.
#' For example, to add a title or change colors:
#' \preformatted{
#' plot_node_degrees(g) +
#'   ggtitle("Degree Distribution") +
#'   scale_fill_manual(values = c("in_degree" = "steelblue", "out_degree" = "salmon"))
#' }
#' @examples
#' library(ig.degree.betweenness)
#' library(igraphdata)
#' data("karate")
#' data("oncology_network")
#' plot_node_degrees(oncology_network)
#' plot_node_degrees(karate)
#' @export
plot_node_degrees <- function(graph){
  # ensure available
  graph <- graph

  # total degree
  all_degree <- tibble::enframe(
    igraph::degree(graph),
    name  = "node",
    value = "degree"
  )

  if (igraph::is_directed(graph)) {
    in_degree  <- tibble::enframe(
      igraph::degree(graph, mode = "in"),
      name  = "node",
      value = "in_degree"
    )
    out_degree <- tibble::enframe(
      igraph::degree(graph, mode = "out"),
      name  = "node",
      value = "out_degree"
    )

    df <- dplyr::full_join(in_degree, out_degree, by = "node") |>
      dplyr::full_join(all_degree,  by = "node") |>
      dplyr::mutate(in_degree = - .data$in_degree) |>
      tidyr::pivot_longer(
        cols      = c("in_degree","out_degree"),
        names_to  = "name",
        values_to = "in-degree/out-degree"
      )

    p <- ggplot2::ggplot(
      df,
      ggplot2::aes(
        y    = stats::reorder(.data$node,   .data$degree),
        x    = .data$`in-degree/out-degree`,
        fill = .data$name
      )
    ) +
      ggplot2::geom_col() +
      ggplot2::theme_minimal() +
      ggplot2::theme(
        axis.title.y    = ggplot2::element_blank(),
        legend.title    = ggplot2::element_blank(),
        legend.position = "bottom"
      )

  } else {
    p <- ggplot2::ggplot(
      all_degree,
      ggplot2::aes(
        y = stats::reorder(.data$node,   .data$degree),
        x = .data$degree
      )
    ) +
      ggplot2::geom_col() +
      ggplot2::theme_minimal() +
      ggplot2::theme(axis.title.y = ggplot2::element_blank())
  }

  p
}
