test_that("test that pipe and bind_loud give same results", {

  r_sqrt <- record(sqrt)
  r_mean <- record(mean)
  r_exp <- record(exp)

  result_pipe <- 1:10 |>
    r_sqrt() %>=%
    r_exp() %>=%
    r_mean()

  result_bind <- 1:10 |>
    r_sqrt() |>
    bind_record(r_exp) |>
    bind_record(r_mean)

  expect_equal(result_pipe$value, result_bind$value)

})


test_that("errors get captured and logs composed", {

  r_sqrt <- record(sqrt)
  r_mean <- record(mean)
  r_exp <- record(exp)

  result_pipe <- -1:-10 |>
    r_mean() %>=%
    r_sqrt() %>=%
    r_exp()

  expect_equal(nrow(result_pipe$log_df), 3)

})


test_that("test that pipe and bind_loud give same results for dplyr functions", {

  r_select <- record(dplyr::select)
  r_filter <- record(dplyr::filter)
  r_group_by <- record(dplyr::group_by)
  r_summarise <- record(dplyr::summarise)

  result_pipe <- mtcars |>
    as_chronicle() %>=%
    r_select(am, starts_with("c")) %>=%
    r_filter(am == 1) %>=%
    r_group_by(carb) %>=%
    r_summarise(mean_cyl = mean(cyl))

  result_bind <- mtcars |>
    as_chronicle() |>
    bind_record(r_select, am, starts_with("c")) |>
    bind_record(r_filter, am == 1) |>
    bind_record(r_group_by, carb) |>
    bind_record(r_summarise, mean_cyl = mean(cyl))

  expect_equal(result_pipe$value, result_bind$value)

})
