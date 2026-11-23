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

  result_pipe <- r_sleep(x = 1) %>=%
    r_sleep(x = 2)

  expect_equal(unveil(result_pipe, "value"), 3)
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

test_that("record and bind_record resolve variables from caller function environment", {
  r_filter <- record(dplyr::filter, .g = dim, strict = 2, diff = "none")
  r_mutate <- record(dplyr::mutate, .g = dim, strict = 2, diff = "none")

  f <- function(df, cyl_keep, gear_keep) {
    df |>
      r_mutate(am2 = am * 2) |>
      bind_record(r_filter, cyl %in% c(cyl_keep, 8), gear == gear_keep)
  }

  res <- f(mtcars, cyl_keep = 4, gear_keep = 4)
  expected <- mtcars |>
    dplyr::mutate(am2 = am * 2) |>
    dplyr::filter(cyl %in% c(4, 8), gear == 4)

  expect_equal(unveil(res, "value"), expected)
  expect_true(all(res$log_df$outcome == "OK! Success"))
})

test_that("record resolves caller variables for direct calls, |>, and %>=% inside functions", {
  r_filter <- record(dplyr::filter)
  r_mutate <- record(dplyr::mutate)
  soma2 <- function(x, y) x + y
  r_soma2 <- record(soma2)

  f_direct <- function(df, cyl_keep) {
    r_filter(df, cyl == cyl_keep)
  }
  f_pipe <- function(df, cyl_keep) {
    df |> r_filter(cyl == cyl_keep)
  }
  f_bind_pipe <- function(df, cyl_keep, mult) {
    df |>
      r_mutate(am2 = am * mult) %>=%
      r_filter(cyl == cyl_keep)
  }
  f_std <- function(a, b) {
    r_soma2(a, y = b)
  }

  expect_equal(
    unveil(f_direct(mtcars, 4), "value"),
    dplyr::filter(mtcars, cyl == 4)
  )
  expect_equal(
    unveil(f_pipe(mtcars, 4), "value"),
    dplyr::filter(mtcars, cyl == 4)
  )
  expect_equal(
    unveil(f_bind_pipe(mtcars, 4, 2), "value"),
    mtcars |> dplyr::mutate(am2 = am * 2) |> dplyr::filter(cyl == 4)
  )
  expect_equal(unveil(f_std(2, 6), "value"), 8)
})

test_that("log_df$message is NA_character_ on success, not literal 'NA'", {
  res <- record(sqrt)(4)
  expect_true(is.na(res$log_df$message))
  expect_identical(res$log_df$message, NA_character_)
})

test_that("read_log supports pretty, table, and errors-only styles", {
  r_sqrt <- record(sqrt)
  r_exp <- record(exp)

  ok_res <- 4 |> r_sqrt() |> bind_record(r_exp)
  pretty_out <- read_log(ok_res, style = "pretty")
  table_out <- read_log(ok_res, style = "table")
  err_ok_out <- read_log(ok_res, style = "errors-only")

  expect_length(pretty_out, 3)
  expect_true(all(grepl("^OK ", pretty_out[1:2])))
  expect_s3_class(table_out, "data.frame")
  expect_equal(nrow(table_out), 2)
  expect_true(all(is.na(table_out$message)))
  expect_true(grepl("Pipeline ran 2 steps successfully", err_ok_out))

  nok_res <- -4 |> r_sqrt() |> bind_record(r_exp)
  err_nok_out <- read_log(nok_res, style = "errors-only")
  expect_length(err_nok_out, 2)
  expect_true(grepl("^NOK `sqrt` failed:", err_nok_out[1]))
})

test_that("fmap_record and flatten_record handle errors, Nothing, and ops_number", {
  ok <- as_chronicle(4) |> fmap_record(sqrt)
  expect_equal(unveil(ok, "value"), 2)
  expect_equal(ok$log_df$ops_number, c(1L, 2L))
  expect_true(all(ok$log_df$outcome == "OK! Success"))

  bad <- as_chronicle(-4) |> fmap_record(sqrt)
  expect_true(maybe::is_nothing(bad$value))
  expect_equal(bad$log_df$ops_number, c(1L, 2L))
  expect_equal(bad$log_df$outcome[2], "NOK! Caution - ERROR")

  upstream_fail <- record(sqrt)(-4) |> fmap_record(exp)
  expect_true(maybe::is_nothing(upstream_fail$value))
  expect_equal(upstream_fail$log_df$ops_number, c(1L, 2L))
  expect_equal(upstream_fail$log_df$message[2], "Pipeline failed upstream")

  nested <- as_chronicle(record(sqrt)(9))
  flat <- flatten_record(nested)
  expect_equal(unveil(flat, "value"), 3)
  expect_equal(flat$log_df$ops_number, c(1L, 2L))
})

test_that("zap_log resets log while keeping value", {
  res <- 4 |> record(sqrt)() |> bind_record(record(exp))
  zapped <- zap_log(res)

  expect_equal(unveil(zapped, "value"), unveil(res, "value"))
  expect_equal(nrow(zapped$log_df), 1)
  expect_equal(zapped$log_df[["function"]], "zap_log")
  expect_error(zap_log(123), "chronicle")
})

test_that("as.data.frame.chronicle coerces tibbles and honours arguments", {
  r_select <- record(dplyr::select)
  tbl_chron <- tibble::as_tibble(mtcars) |> r_select(mpg, cyl)
  df_out <- as.data.frame(tbl_chron, row.names = paste0("r", seq_len(nrow(mtcars))))

  expect_identical(class(df_out), "data.frame")
  expect_equal(rownames(df_out)[1], "r1")

  bad_chron <- record(sqrt)(-1)
  expect_error(as.data.frame(bad_chron), "cannot be coerced to a data.frame")
})

test_that("check_diff and check_g validate chronicle input and return expected columns", {
  r_mutate <- record(dplyr::mutate, diff = "summary")
  res <- r_mutate(mtcars, am2 = am * 2)
  diffs <- check_diff(res)

  expect_s3_class(diffs, "data.frame")
  expect_true("diff_obj" %in% names(diffs))
  expect_error(check_g(mtcars), "chronicle")
  expect_error(check_diff(mtcars), "chronicle")
})

test_that("record_many strips package namespaces cleanly", {
  skip_if_not_installed("clipr")
  captured <- NULL
  testthat::local_mocked_bindings(
    write_clip = function(content, ...) {
      captured <<- content
      invisible(content)
    },
    .package = "clipr"
  )
  expect_message(
    record_many(list("exp", "dplyr::select")),
    "Code copied to clipboard"
  )
  expect_true(grepl("^r_exp <- record\\(exp", captured[1]))
  expect_true(grepl("^r_select <- record\\(dplyr::select", captured[2]))
})
