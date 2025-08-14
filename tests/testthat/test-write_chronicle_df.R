test_that("write_chronicle_df csv output matches snapshot", {
  r_group_by <- record(dplyr::group_by)
  r_select <- record(dplyr::select)
  r_summarise <- record(dplyr::summarise)
  r_filter <- record(dplyr::filter)

  output <- dplyr::starwars |>
    r_select(height, mass, species, sex) |>
    bind_record(r_group_by, species, sex) |>
    bind_record(r_filter, sex != "male") |>
    bind_record(r_summarise, mass = mean(mass, na.rm = TRUE))

  temp_csv_path <- tempfile(fileext = ".csv")
  on.exit(unlink(temp_csv_path))

  write_chronicle_df(output, temp_csv_path)

  expected <- dplyr::starwars |>
    dplyr::select(height, mass, species, sex) |>
    dplyr::group_by(species, sex) |>
    dplyr::filter(sex != "male") |>
    dplyr::summarise(mass = mean(mass, na.rm = TRUE))

  actual <- read.csv(temp_csv_path, skip = 8)

  # Can't test the log because of the timestamp
  # so no snapshot tests
  expect_equal(actual, expected, ignore_attr = TRUE)
})


test_that("write_chronicle_df xlsx content matches snapshot", {
  skip_if_not_installed("openxlsx")

  r_group_by <- record(dplyr::group_by)
  r_select <- record(dplyr::select)
  r_summarise <- record(dplyr::summarise)
  r_filter <- record(dplyr::filter)

  output <- dplyr::starwars %>%
    r_select(height, mass, species, sex) %>%
    bind_record(r_group_by, species, sex) %>%
    bind_record(r_filter, sex != "male") %>%
    bind_record(r_summarise, mass = mean(mass, na.rm = TRUE))

  temp_xlsx_path <- tempfile(fileext = ".xlsx")
  on.exit(unlink(temp_xlsx_path))

  write_chronicle_df(output, temp_xlsx_path)

  expected <- dplyr::starwars |>
    dplyr::select(height, mass, species, sex) |>
    dplyr::group_by(species, sex) |>
    dplyr::filter(sex != "male") |>
    dplyr::summarise(mass = mean(mass, na.rm = TRUE))

  actual <- openxlsx::read.xlsx(temp_xlsx_path)

  # Can't test the log because of the timestamp
  # so no snapshot tests
  expect_equal(actual, expected, ignore_attr = TRUE)
})
