#' Analyze Degree Balance of a Graph
#'
#' Computes and summarizes vertex degree distributions for an `igraph`
#' object. For directed graphs, the function reports in-degree and out-degree
#' statistics, including their correlation and mean values. For undirected
#' graphs, only overall degree statistics are reported.
#'
#' @param g An `igraph` graph object.
#'
#' @details
#' If the graph is directed (see `igraph::is_directed()`), the function:
#' \itemize{
#'   \item Computes in-degree and out-degree for each vertex.
#'   \item Prints summary statistics for both distributions.
#'   \item Reports the correlation between in-degree and out-degree.
#'   \item Reports mean in-degree and mean out-degree.
#' }
#'
#' If the graph is undirected, the function:
#' \itemize{
#'   \item Computes the degree for each vertex.
#'   \item Prints summary statistics of the degree distribution.
#' }
#'
#' @return
#' A list containing:
#' \itemize{
#'   \item `out_degree` Numeric vector of out-degrees (directed graphs only).
#'   \item `in_degree` Numeric vector of in-degrees (directed graphs only).
#'   \item `degree` Numeric vector of degrees (undirected graphs only).
#' }
#'
#' @importFrom stats cor
#'
#' @examples
#' library(igraph)
#' library(ig.degree.betweenness)
#'
#' # Directed graph example
#' g_directed <- make_ring(10, directed = TRUE)
#' degree_balance(g_directed)
#'
#' # Undirected graph example
#' g_undirected <- make_ring(10)
#' degree_balance(g_undirected)
#'
#' @export
degree_balance <- function(g) {
  if (igraph::is_directed(g)) {
    out_deg <- igraph::degree(g, mode = "out")
    in_deg <- igraph::degree(g, mode = "in")

    cat("Out-degree stats:\n")
    print(summary(out_deg))
    cat("\nIn-degree stats:\n")
    print(summary(in_deg))
    cat("\nCorrelation between in and out degree:", stats::cor(in_deg, out_deg), "\n")
    cat("Mean out-degree:", mean(out_deg), "\n")
    cat("Mean in-degree:", mean(in_deg), "\n")

    return(list(out_degree = out_deg, in_degree = in_deg))
  } else {
    deg <- igraph::degree(g)
    cat("Degree stats:\n")
    print(summary(deg))
    return(list(degree = deg))
  }
}

