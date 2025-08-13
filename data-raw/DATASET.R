## code to prepare `DATASET` dataset goes here

avia <- readr::read_tsv("~/Downloads/avia_par_lu.tsv") %>%
  as_tibble()

usethis::use_data(avia, overwrite = TRUE)

#avia <- readr::read_tsv("https://ec.europa.eu/eurostat/api/dissemination/sdmx/2.1/data/avia_par_lu?format=tsv&compressed=false") %>%
#  filter(!grepl("^A.*", `freq,unit,tra_meas,airp_pr\\TIME_PERIOD`))
