#' Zap the log of a chronicle object
#'
#' @description
#' This function replaces the entire existing log of a `chronicle` object with a
#' single, new entry. This new entry simply records that the log was "zapped"
#' and the time at which it occurred.
#'
#' This is useful for simplifying a `chronicle` object before saving or sharing,
#' or to mark a definitive checkpoint in a workflow, effectively discarding the
#' previous history. The underlying `value` of the object remains completely
#' unchanged.
#'
#' @param .c A `chronicle` object.
#'
#' @return A new `chronicle` object with the same `value` as the input, but with
#' its `log_df` replaced by a single entry.
#' @importFrom tibble tibble
#' @importFrom rlang `%||%`
#' @export
#' @examples
#' library(dplyr)
#'
#' # 1. Create a chronicle object with a multi-step log
#' r_select <- record(select)
#' r_filter <- record(filter)
#'
#' original_chronicle <- starwars %>%
#'   r_select(name, height, mass, species) %>%
#'   bind_record(r_filter, species == "Human")
#'
#' # 2. View the original, detailed log
#' cat("--- Original Log ---\n")
#' read_log(original_chronicle)
#'
#' # 3. Zap the log
#' zapped_chronicle <- zap_log(original_chronicle)
#'
#' # 4. View the new, simplified log
#' cat("\n--- Zapped Log ---\n")
#' read_log(zapped_chronicle)
#'
#' # 5. The underlying data value is unaffected
#' identical(
#'   unveil(original_chronicle, "value"),
#'   unveil(zapped_chronicle, "value")
#' )
#'
zap_log <- function(.c) {
  # Ensure the input is a valid chronicle object
  if (!is_chronicle(.c)) {
    stop("Input must be an object of class 'chronicle'.", call. = FALSE)
  }

  zap_time <- Sys.time()

  # Create a new, single-row log data frame from scratch.
  # This ensures it's valid and contains only the "zapped" entry.
  new_log_df <- tibble::tibble(
    ops_number = 1L,
    outcome = "OK! Success",
    `function` = "zap_log", # Use backticks for the column name
    arguments = NA_character_,
    message = sprintf("Log zapped at %s", zap_time),
    start_time = zap_time,
    end_time = zap_time,
    run_time = as.difftime(0, units = "secs"),
    g = list(NA),
    diff_obj = list(NULL),
    lag_outcome = NA_character_
  )

  # Reconstruct the chronicle object with the original value but the new log
  list(
    value = .c$value,
    log_df = new_log_df
  ) |>
    structure(class = "chronicle")
}
