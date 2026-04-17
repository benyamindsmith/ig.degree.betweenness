#' Generate Linearized Chord Diagram (LCD) Graphs
#'
#' @description `r lifecycle::badge("experimental")`
#'
#' A family of functions to generate networks based on the Linearized Chord Diagram
#' (LCD) model using preferential attachment. The suite includes the standard LCD
#' model as well as variants that introduce bidirectional edges, alternating direction
#' attachment, and mixed degree preferences.
#'
#' @details
#' The standard `lcd_graph` function builds a network step-by-step. At each time step
#' `t` from 1 to `n`, a new node is added and generates `m` edges. The target of each
#' edge is chosen preferentially based on the degree of the existing nodes.
#'
#' The package also provides three variations:
#' * \code{lcd_graph_bidirectional}: Adds a primary edge and, with a specified
#'   probability, simultaneously adds a reverse edge.
#' * \code{lcd_graph_alternating}: Alternates between using out-degree and in-degree
#'   pools for preferential attachment targets.
#' * \code{lcd_graph_mixed}: Chooses between out-degree and in-degree pools for
#'   attachment based on a weighted probability.
#'
#' @param n Integer. The total number of vertices (nodes) in the generated graph.
#' @param m Integer. The number of edges each new node adds during its time step.
#'   Defaults to 1.
#' @param directed Logical. Whether the generated graph should be directed.
#'   Defaults to \code{TRUE}.
#' @param bidirectional_prob Numeric. The probability (between 0 and 1) of adding
#'   a reverse edge (target -> source) when generating bidirectional graphs.
#'   Used only in \code{lcd_graph_bidirectional}. Defaults to 0.5.
#' @param out_weight Numeric. The probability weight (between 0 and 1) given to
#'   the out-degree pool versus the in-degree pool. Used only in \code{lcd_graph_mixed}.
#'   Defaults to 0.5.
#'
#' @return An \code{igraph} object representing the generated LCD graph.
#'
#' @name lcd_graphs
#' @aliases lcd_graph lcd_graph_bidirectional lcd_graph_alternating lcd_graph_mixed
#'
#' @importFrom stats runif
#'
#' @examples
#' # Generate a standard directed LCD graph with 100 nodes and 2 edges per step
#' g1 <- lcd_graph(n = 100, m = 2)
#'
#' # Generate a graph where reverse edges appear 30% of the time
#' g2 <- lcd_graph_bidirectional(n = 100, m = 1, bidirectional_prob = 0.3)
#'
#' # Generate a graph alternating between in-degree and out-degree attachment
#' g3 <- lcd_graph_alternating(n = 100, m = 3)
#'
#' # Generate a mixed graph favoring out-degree attachment 70% of the time
#' g4 <- lcd_graph_mixed(n = 100, m = 2, out_weight = 0.7)
#'
#' @references
#' Barabási, A.-L. (2016). \emph{Network Science}. Cambridge University Press. Chapter 5: The Barabási-Albert Model. \url{https://networksciencebook.com/chapter/5}
#' @rdname lcd_graphs
#' @export
lcd_graph <- function(n, m = 1, directed = TRUE) {

  endpoints <- integer(0)  # stub list for preferential attachment
  deg <- integer(n)        # degree (total degree for undirected, out+in for directed)
  edge_list <- integer(0)  # edge pairs

  for (t in seq_len(n)) {
    for (link_i in seq_len(m)) {
      len <- length(endpoints)
      denom <- len + 1  # corresponds to 2t - 1 when m = 1
      r <- sample.int(denom, 1)
      if (r == denom) {
        target <- t  # self-loop
      } else {
        target <- endpoints[r]
      }

      # Directed vs undirected edge recording
      if (directed) {
        # Always from new node t -> target
        edge_list <- c(edge_list, t, target)
      } else {
        # Store as undirected pair (order doesn't matter)
        edge_list <- c(edge_list, t, target)
      }

      # Degree updates and endpoint tracking
      if (target == t) {
        deg[t] <- deg[t] + if (directed) 1 else 2
        endpoints <- c(endpoints, t, t)
      } else {
        deg[t] <- deg[t] + 1
        deg[target] <- deg[target] + 1
        endpoints <- c(endpoints, t, target)
      }
    }
  }

  edges_mat <- matrix(edge_list, ncol = 2, byrow = TRUE)
  g <- igraph::graph_from_edgelist(edges_mat, directed = directed)

  return(g)
}

#' @rdname lcd_graphs
#' @export
lcd_graph_bidirectional <- function(n, m = 1, directed = TRUE, bidirectional_prob = 0.5) {

  endpoints <- integer(0)
  deg <- integer(n)
  edge_list <- integer(0)

  for (t in seq_len(n)) {
    for (link_i in seq_len(m)) {
      len <- length(endpoints)
      denom <- len + 1
      r <- sample.int(denom, 1)
      if (r == denom) {
        target <- t  # self-loop
      } else {
        target <- endpoints[r]
      }

      # Add the primary edge (t -> target)
      edge_list <- c(edge_list, t, target)

      # With some probability, also add reverse edge (target -> t)
      if (directed && target != t && runif(1) < bidirectional_prob) {
        edge_list <- c(edge_list, target, t)
      }

      # Degree updates
      if (target == t) {
        deg[t] <- deg[t] + if (directed) 1 else 2
        endpoints <- c(endpoints, t, t)
      } else {
        deg[t] <- deg[t] + 1
        deg[target] <- deg[target] + 1
        endpoints <- c(endpoints, t, target)
      }
    }
  }

  edges_mat <- matrix(edge_list, ncol = 2, byrow = TRUE)
  g <- igraph::graph_from_edgelist(edges_mat, directed = directed)

  return(g)
}

#' @rdname lcd_graphs
#' @export
lcd_graph_alternating <- function(n, m = 1, directed = TRUE) {

  out_endpoints <- integer(0)  # for out-degree based attachment
  in_endpoints <- integer(0)   # for in-degree based attachment
  deg_out <- integer(n)
  deg_in <- integer(n)
  edge_list <- integer(0)

  for (t in seq_len(n)) {
    for (link_i in seq_len(m)) {
      # Alternate between using out-degree and in-degree for preferential attachment
      if (link_i %% 2 == 1) {
        # Use out-degree based attachment (t -> target)
        len <- length(out_endpoints)
        denom <- len + 1
        r <- sample.int(denom, 1)
        if (r == denom) {
          target <- t
        } else {
          target <- out_endpoints[r]
        }
        edge_list <- c(edge_list, t, target)

        if (target == t) {
          deg_out[t] <- deg_out[t] + 1
          deg_in[t] <- deg_in[t] + 1
          out_endpoints <- c(out_endpoints, t)
          in_endpoints <- c(in_endpoints, t)
        } else {
          deg_out[t] <- deg_out[t] + 1
          deg_in[target] <- deg_in[target] + 1
          out_endpoints <- c(out_endpoints, t)
          in_endpoints <- c(in_endpoints, target)
        }
      } else {
        # Use in-degree based attachment (target -> t)
        len <- length(in_endpoints)
        denom <- len + 1
        r <- sample.int(denom, 1)
        if (r == denom) {
          source <- t
        } else {
          source <- in_endpoints[r]
        }
        edge_list <- c(edge_list, source, t)

        if (source == t) {
          deg_out[t] <- deg_out[t] + 1
          deg_in[t] <- deg_in[t] + 1
          out_endpoints <- c(out_endpoints, t)
          in_endpoints <- c(in_endpoints, t)
        } else {
          deg_out[source] <- deg_out[source] + 1
          deg_in[t] <- deg_in[t] + 1
          out_endpoints <- c(out_endpoints, source)
          in_endpoints <- c(in_endpoints, t)
        }
      }
    }
  }

  edges_mat <- matrix(edge_list, ncol = 2, byrow = TRUE)
  g <- igraph::graph_from_edgelist(edges_mat, directed = directed)

  return(g)
}

#' @rdname lcd_graphs
#' @export
lcd_graph_mixed <- function(n, m = 1, directed = TRUE, out_weight = 0.5) {

  endpoints_out <- integer(0)  # weighted by out-degree
  endpoints_in <- integer(0)   # weighted by in-degree
  deg_out <- integer(n)
  deg_in <- integer(n)
  edge_list <- integer(0)

  for (t in seq_len(n)) {
    for (link_i in seq_len(m)) {
      # Combine both in and out degree pools for attachment
      total_out <- length(endpoints_out)
      total_in <- length(endpoints_in)

      # Weight the selection between out-degree and in-degree based pools
      if (total_out == 0 && total_in == 0) {
        target <- t  # First node case
      } else if (total_out == 0) {
        # Only in-degree pool available
        target <- endpoints_in[sample.int(total_in, 1)]
      } else if (total_in == 0) {
        # Only out-degree pool available
        target <- endpoints_out[sample.int(total_out, 1)]
      } else {
        # Choose between pools based on weight
        if (runif(1) < out_weight) {
          r <- sample.int(total_out + 1, 1)
          if (r == total_out + 1) {
            target <- t
          } else {
            target <- endpoints_out[r]
          }
        } else {
          r <- sample.int(total_in + 1, 1)
          if (r == total_in + 1) {
            target <- t
          } else {
            target <- endpoints_in[r]
          }
        }
      }

      edge_list <- c(edge_list, t, target)

      # Update degrees and endpoint pools
      if (target == t) {
        deg_out[t] <- deg_out[t] + 1
        deg_in[t] <- deg_in[t] + 1
        endpoints_out <- c(endpoints_out, t)
        endpoints_in <- c(endpoints_in, t)
      } else {
        deg_out[t] <- deg_out[t] + 1
        deg_in[target] <- deg_in[target] + 1
        endpoints_out <- c(endpoints_out, t)
        endpoints_in <- c(endpoints_in, target)
      }
    }
  }

  edges_mat <- matrix(edge_list, ncol = 2, byrow = TRUE)
  g <- igraph::graph_from_edgelist(edges_mat, directed = directed)

  return(g)
}
