test_that("ggplot function get recorded", {
  expect_true(ggplot2::is.ggplot(
  (maybe::from_maybe(
    (ggrecord(ggplot)(mtcars))$gg,
    default = maybe::nothing())
  ))
  )
  expect_true(ggplot2::is.ggproto(
  (maybe::from_maybe(
    (ggrecord(geom_point)(aes(mpg, hp)))$gg,
    default = maybe::nothing()
  ))
  ))
})

test_that("ggrecorded functions can be added", {
  r_ggplot <- ggrecord(ggplot)
  r_geom_line <- ggrecord(geom_line)
  r_labs <- ggrecord(labs)

  a <- r_ggplot(mtcars) %>+%
    r_geom_line(aes(y = mpg, x = hp)) %>+%
    r_labs(title = "ggrecorded functions can be added",
           subtitle = "This is the subtitle")

  expect_true(is_chronicle(a))
  expect_true(is.ggplot(a$gg))
  print(a$gg)

  b <- a %>+%
    r_labs(subtitle = "log in the caption", caption = a$log)

  print(b$gg)
})

test_that("purely works on ggplot", {
  expect_true(FALSE)
})
