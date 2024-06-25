test_that("find_connected_components", {

  connections <- list(
    c(1,2), c(2, 5), c(4, 3, 5),
    c(6, 7),
    c(8)
  )

  res <- find_connected_components(connections)
  expect_setequal(res[[1]], c(1,2,3,4,5))
  expect_setequal(res[[2]], c(6, 7))
  expect_setequal(res[[3]], c(8))
  expect_equal(length(res), 3)

  system.time(
    res <- find_connected_components(list(1:1000))
  )
  expect_setequal(res[[1]], 1:1000)
})

test_that("find_connected_components finds same components as igraph", {
  testthat::skip_if_not_installed("igraph")
  # Check results against igraph
  edges <- as.character(as.integer(sample(1:500, size = 600, replace = TRUE)))
  gr <- igraph::make_undirected_graph(edges)
  connections <- asplit(igraph::as_edgelist(gr), 1)
  res <- find_connected_components(connections)
  ires <- igraph::components(gr)
  expect_equal(sort(lengths(res)), sort(ires$csize))

  mem <- ires$membership
  ires_list <- lapply(seq_len(max(mem)), \(idx){
    names(mem)[mem == idx]
  })
  for(comp in res){
    matched <- FALSE
    for(comp2 in ires_list){
      if(length(comp) == length(comp2) && all(sort(comp) == sort(comp2))){
        matched <- TRUE
        break
      }
    }
    expect_true(matched)
  }

})
