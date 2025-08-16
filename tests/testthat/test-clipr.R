test_that("error message if clipr not available", {
  # Skip on my local machine
  skip_if(
    Sys.getenv("NIX_USER_PROFILE_DIR") ==
      "/nix/var/nix/profiles/per-user/brodrigues"
  )
  skip_on_cran()
  expect_error(record_many(NULL), "*install*")
})
