# Test 1: Verify that record_ggplot returns a chronicle object
test_that("record_ggplot returns a chronicle object", {

  # Define the ggplot expression
  gg_expr <- ggplot(data = mtcars) + geom_point(aes(y = hp, x = mpg))

  # Record the ggplot expression and store the chronicle object
  gg_chronicle <- record_ggplot(gg_expr)

  # Verify that the chronicle object is of class 'chronicle'
  expect_true(inherits(gg_chronicle, "chronicle"))
})

# Test 2: Verify that the chronicle object contains a ggplot object
test_that("the chronicle object produced by record_ggplot contains a ggplot object", {

  # Define the ggplot expression
  gg_expr <- ggplot(data = mtcars) + geom_point(aes(y = hp, x = mpg))

  # Record the ggplot expression and store the chronicle object
  gg_chronicle <- record_ggplot(gg_expr)

  # Retrieve the value from the chronicle object
  gg_chronicle_value <- pick(gg_chronicle, "value")

  # Verify that the value is a ggplot object
  expect_true(is.ggplot(gg_chronicle_value))
})

# Test 3: Verify that record_ggplot returns expected ggplot "recipe"
test_that("record_ggplot returns expected ggplot recipe", {
  # Create a ggplot expression
  gg_expr <- ggplot(data = mtcars) + geom_point(aes(y = hp, x = mpg))
  
  # Record the ggplot using record_ggplot function
  gg_chronicle <- record_ggplot(gg_expr)
  
  # Extract the ggplot recipe from the gg_chronicle object
  gg_chronicle_recipe <- pick(gg_chronicle, "value")
  
  # Check if the original ggplot expression and the recorded recipe are identical
  # Please note the usage of as.character, that's because we want to compare
  # string representations of ggplot expression.
  # The reason is that the ggplot object contains some variables tied to environment
  # and these are different in record_ggplot() output. This shouldn't have a negative
  # impact on the performance of record_ggplot. 
  expect_identical(as.character(gg_expr), as.character(gg_chronicle_recipe))
  
})

# Test 4: Verify that record_ggplot returns expected ggplot "recipe" components
# I have introduced this test because of the usage of as.character above, 
# to make sure that the ggplot "recipe" is really correct. 
test_that("record_ggplot returns expected ggplot recipe", {
  
  # Define the ggplot expression
  gg_expr <- ggplot(data = mtcars) + 
    geom_point(aes(y = hp, x = mpg)) + 
    scale_x_continuous(name = "Miles per gallon") +
    scale_y_continuous(name = "Horsepower") +
    labs(title = "MTcars data")
  
  # Record the ggplot expression and store the chronicle object
  gg_chronicle <- record_ggplot(gg_expr)
  
  # Retrieve the value from the chronicle object
  gg_chronicle_value <- pick(gg_chronicle, "value")
  
  # Convert the ggplot objects to list structures
  gg_expr_list <- ggplot_build(gg_expr)
  gg_chronicle_recipe_list <- ggplot_build(gg_chronicle_value)
  
  # Check the aes mapping
  expect_identical(gg_expr_list$data[[1]]$mapping, gg_chronicle_recipe_list$data[[1]]$mapping)
  
  # Check the geom layer
  expect_identical(gg_expr_list$layers[[1]]$geom$geomname, gg_chronicle_recipe_list$layers[[1]]$geom$geomname)
  
  # Check the x scale
  expect_identical(gg_expr_list$scales$x[[1]]$name, gg_chronicle_recipe_list$scales$x[[1]]$name)
  
  # Check the y scale
  expect_identical(gg_expr_list$scales$y[[1]]$name, gg_chronicle_recipe_list$scales$y[[1]]$name)
  
  # Check the plot title
  expect_identical(gg_expr_list$plot$title, gg_chronicle_recipe_list$plot$title)
})

# Test 5: Verify that record_ggplot produces the same output as the original expression
# Probably the main test
test_that("record_ggplot produces the same output as the original expression", {
  
  # Define the ggplot expression
  gg_expr <- ggplot(data = mtcars) + geom_point(aes(y = hp, x = mpg))
  
  # Record the ggplot expression and store the chronicle object
  gg_chronicle <- record_ggplot(gg_expr)
  
  # Render the original ggplot
  orig_plot <- ggplot(data = mtcars) + geom_point(aes(y = hp, x = mpg))
  orig_plot_file <- tempfile(fileext = ".png")
  ggsave(orig_plot_file, orig_plot)
  
  # Render the chronicle ggplot
  chronicle_plot <- pick(gg_chronicle, "value")
  chronicle_plot_file <- tempfile(fileext = ".png")
  ggsave(chronicle_plot_file, chronicle_plot)
  
  # Verify that the rendered plots are identical
  expect_identical(readBin(orig_plot_file, what = "raw"), readBin(chronicle_plot_file, what = "raw"))
})
