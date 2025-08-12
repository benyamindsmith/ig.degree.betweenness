#' Analyze Degree Balance
#' @export

degree_balance <- function(g) {
  if (igraph::is_directed(g)) {
    out_deg <- igraph::degree(g, mode = "out")
    in_deg <- igraph::degree(g, mode = "in")

    cat("Out-degree stats:\n")
    print(summary(out_deg))
    cat("\nIn-degree stats:\n")
    print(summary(in_deg))
    cat("\nCorrelation between in and out degree:", cor(in_deg, out_deg), "\n")
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

