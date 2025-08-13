# tests/testthat/test-ggplot_fun.R

# Test that the function correctly records a successful ggplot expression
test_that("record_ggplot captures a successful plot correctly", {

  # Create a valid ggplot object using the function
  chronicled_plot <- record_ggplot(
    ggplot(mtcars, aes(x = mpg, y = hp)) + geom_point()
  )

  # 1. Check that the chronicle object itself is valid
  expect_s3_class(chronicled_plot, "chronicle")

  # 2. Check the log for success
  log_df <- pick(chronicled_plot, "log_df")
  expect_true(grepl("OK! Success", log_df$outcome))
  expect_true(grepl("ggplot\\(mtcars", log_df$`function`))

  # 3. Check that the value is a ggplot object and not Nothing
  plot_value <- pick(chronicled_plot, "value")
  expect_s3_class(plot_value, "ggplot")
  expect_false(is_nothing(chronicled_plot$value))

  # 4. Check that it's the *original* plot, not the error plot
  # The error plot has a specific theme element we can check for.
  expect_null(plot_value$theme$plot.background)
})


# Test that the function handles a plot failure and returns an error plot
test_that("record_ggplot handles a plot failure and creates an error plot", {

  # Create a plot with an invalid aesthetic mapping ('mpgg')
  chronicled_plot <- record_ggplot(
    ggplot(mtcars, aes(x = mpgg, y = hp)) + geom_point()
  )

  # 1. Check that the chronicle object is valid
  expect_s3_class(chronicled_plot, "chronicle")

  # 2. Check the log for failure and the correct error message
  log_df <- pick(chronicled_plot, "log_df")
  expect_true(grepl("NOK! Caution - ERROR", log_df$outcome))
  expect_true(grepl("object 'mpgg' not found", log_df$message))

  # 3. Check that the value is NOT Nothing, but is a ggplot object
  plot_value <- pick(chronicled_plot, "value")
  expect_false(is_nothing(chronicled_plot$value))
  expect_s3_class(plot_value, "ggplot")

  # 4. Verify that the returned plot is the *error plot*
  # We can do this by checking for properties we know the error plot has.
  expect_equal(plot_value$theme$plot.background$fill, "#FFDDDD")
  expect_length(plot_value$layers, 1)
  expect_s3_class(plot_value$layers[[1]]$geom, "GeomText")
})


# Test the behavior of the `strict` parameter
test_that("record_ggplot respects the 'strict' parameter for warnings", {

  # Create a dataframe with a missing value
  df_with_na <- data.frame(x = 1:5, y = c(1, 2, 100, 4, 5))

  # ---- Scenario 1: strict = 2 (default, captures warnings) ----
  chronicled_plot_strict2 <- record_ggplot(
    ggplot(df_with_na, aes(x, y)) + geom_line() + ylim(0,3),
    strict = 2
  )

  # Log should show failure because a warning was caught
  log_df_strict2 <- pick(chronicled_plot_strict2, "log_df")
  expect_true(grepl("NOK! Caution - ERROR", log_df_strict2$outcome))
  expect_true(grepl("Removed 1 row", log_df_strict2$message))

  # Value should be the error plot displaying the warning
  plot_value_strict2 <- pick(chronicled_plot_strict2, "value")
  expect_s3_class(plot_value_strict2, "ggplot")
  expect_equal(plot_value_strict2$theme$plot.background$fill, "#FFDDDD")


  # ---- Scenario 2: strict = 1 (errors only, ignores warnings) ----
  chronicled_plot_strict1 <- record_ggplot(
    ggplot(df_with_na, aes(x, y)) + geom_line(),
    strict = 1
  )

  # Log should show success because the warning was ignored
  log_df_strict1 <- pick(chronicled_plot_strict1, "log_df")
  expect_true(grepl("OK! Success", log_df_strict1$outcome))
  expect_equal(log_df_strict1$message, "NA")

  # Value should be the original ggplot, not the error plot
  plot_value_strict1 <- pick(chronicled_plot_strict1, "value")
  expect_s3_class(plot_value_strict1, "ggplot")
  expect_null(plot_value_strict1$theme$plot.background)
})


# Test that the error plot contains the correct message in its layer
test_that("The error plot's annotation layer contains the correct error message", {

  error_message <- "object 'mpgg' not found"

  chronicled_plot <- record_ggplot(
    ggplot(mtcars, aes(x = mpgg, y = hp)) + geom_point()
  )

  plot_value <- pick(chronicled_plot, "value")

  # Extract the label from the ggplot's layer aesthetic
  error_label_in_plot <- plot_value$layers[[1]]$aes_params$label

  # Check that the actual error message from the log is present in the plot's label
  log_message <- pick(chronicled_plot, "log_df")$message
  expect_true(grepl(error_message, log_message))
  # The label in the plot is wrapped, so we test if the log message is contained within it
  expect_true(grepl(stringr::str_wrap(log_message, 40), error_label_in_plot, fixed = TRUE))
})
