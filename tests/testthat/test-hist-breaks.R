test_that("heap_step finds the rounding step of heaped data", {
  set.seed(1)
  w <- round(rnorm(2000, 190, 20) / 5) * 5          # weights to the nearest 5 lb
  w[1:100] <- w[1:100] + 1                          # a few exact values
  expect_equal(heap_step(w), 5)

  expect_equal(heap_step(round(rnorm(500, 50000, 9000), -3)), 1000)
  expect_equal(heap_step(sample(0:160, 1000, TRUE)), 1)          # plain integers
  expect_true(is.na(heap_step(runif(500))))                      # continuous
  # a pile of zeros must not fake a large step
  expect_equal(heap_step(c(rep(0, 900), sample(1:97, 100, TRUE))), 1)
})

test_that("hist_breaks sits on the step so every bin holds the same values", {
  set.seed(2)
  w <- round(rnorm(3000, 200, 15) / 5) * 5
  b <- hist_breaks(w)
  width <- unique(round(diff(b), 8))
  expect_length(width, 1)
  expect_equal(width %% 5, 0)
  expect_true(all(abs(b / 5 - round(b / 5)) < 1e-8))
  expect_true(min(b) <= min(w) && max(b) > max(w))
  h <- hist(w, breaks = b, right = FALSE, plot = FALSE)
  expect_equal(sum(h$counts), length(w))

  # unheaped data keeps exactly 50 bins over its range
  x <- runif(400, 3, 9)
  expect_length(hist_breaks(x), 51)
})
