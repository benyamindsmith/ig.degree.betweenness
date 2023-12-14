test_that(
  "karate dataset works",
  {
    library(igraphdata)
    data("karate")
    expect_no_error(cluster_node_degree(karate))
  }
)

test_that(
  "yeast dataset works",
  {
    library(igraphdata)
    data("yeast")
    expectdegree(cluster_node_closeness(yeast))
  }
)
