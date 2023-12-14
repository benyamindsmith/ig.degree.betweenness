test_that(
  "karate dataset works",
  {
    library(igraphdata)
    data("karate")
    expect_no_error(cluster_node_closeness(karate))
  }
)

test_that(
  "yeast dataset works",
  {
    library(igraphdata)
    data("yeast")
    expect_no_error(cluster_node_closeness(yeast))
  }
)
