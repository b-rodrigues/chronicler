test_that("first and only error message is ok", {
  r_select <- record(dplyr::select)

  result_pipe <- mtcars |>
    r_select(bm)

  expect_true(grepl(
    "Can't select columns that don't exist",
    result_pipe$log_df$message
  ))
})


test_that("if multiple error messages, next ones are 'pipe failed'", {
  r_select <- record(dplyr::select)
  r_filter <- record(dplyr::filter)
  r_mutate <- record(dplyr::mutate)

  result_pipe <- mtcars |>
    r_select(bm) %>=%
    r_filter(bm == 1) %>=%
    r_mutate(bm = 3)

  expect_true(grepl(
    "Can't select columns that don't exist",
    result_pipe$log_df$message[1]
  ))
  expect_true(grepl("Pipeline failed upstream", result_pipe$log_df$message[2]))
  expect_true(grepl("Pipeline failed upstream", result_pipe$log_df$message[3]))
})

testthat::test_that("test check_g", {
  r_select <- record(dplyr::select, .g = dim)

  result_pipe <- mtcars |>
    r_select(am)

  expected_result <- tibble::tribble(
    ~ops_number,
    ~`function`,
    ~g,
    1,
    "dplyr::select",
    c(32, 1)
  ) |>
    as.data.frame()

  expect_equal(check_g(result_pipe), expected_result)
})

test_that("test running time", {
  sleeping <- function(x, y = 0) {
    Sys.sleep(x)
    x + y
  }

  r_sleep <- record(sleeping)

  result_pipe <- r_sleep(1) %>=%
    r_sleep(2)

  expect_equal(sum(as.integer(result_pipe$log_df$run_time)), 3)
})

test_that("record handles named and unnamed arguments for standard functions", {
  # single argument function
  mode <- function(x) {
    ux <- unique(x)
    ux[which.max(tabulate(match(x, ux)))]
  }
  r_mode <- record(mode, .g = length)
  vetor <- c(3, 1, 2, 5, 9, 3, 2, 2, 5, 8, 4, 1)

  # works with unnamed argument
  res_unnamed <- r_mode(vetor)
  expect_equal(unveil(res_unnamed, "value"), 2)
  expect_equal(check_g(res_unnamed)$g[[1]], 1)

  # works with named argument
  res_named <- r_mode(x = vetor)
  expect_equal(unveil(res_named, "value"), 2)
  expect_equal(check_g(res_named)$g[[1]], 1)

  # multi-argument function
  soma2 <- function(x, y) {
    res <- x + y
    return(res)
  }
  r_soma2 <- record(soma2, .g = length)

  # works with positional arguments
  res_pos <- r_soma2(2, 6)
  expect_equal(unveil(res_pos, "value"), 8)

  # works with mixed arguments
  res_mixed <- r_soma2(2, y = 6)
  expect_equal(unveil(res_mixed, "value"), 8)

  # works with fully named arguments
  res_named_multi <- r_soma2(x = 2, y = 6)
  expect_equal(unveil(res_named_multi, "value"), 8)
})
