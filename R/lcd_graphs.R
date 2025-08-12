#' Linearized Chord Diagram Graph Generating functions
#'
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


# Option 1: Bidirectional edges with probability
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

# Option 2: Alternating direction with preferential attachment
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

# Option 3: Mixed preferential attachment (balance in/out degree preference)
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
