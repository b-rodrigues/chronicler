## code to prepare `DATASET` dataset goes here

avia <- readr::read_tsv("~/Downloads/avia_par_lu.tsv") %>%
  as_tibble()

usethis::use_data(avia, overwrite = TRUE)

