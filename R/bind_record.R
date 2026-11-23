#' Evaluate a decorated function; used to chain multiple decorated functions.
#' @param .c A chronicle object.
#' @param .f A chronicle function to apply to the returning value of .c.
#' @param ... Further parameters to pass to .f.
#' @return A chronicle object.
#' @importFrom maybe from_maybe nothing
#' @examples
#' r_sqrt <- record(sqrt)
#' r_exp <- record(exp)
#' 3 |> r_sqrt() |> bind_record(r_exp)
#' @export
bind_record <- function(.c, .f, ...) {
  .f(
    maybe::from_maybe(.c$value, default = maybe::nothing()),
    ...,
    .log_df = .c$log_df
  )
}

#' Flatten nested chronicle objects
#' @param .c A nested chronicle object, where the $value element is itself a chronicle object
#' @return Returns `.c` where value is the actual value, and logs are concatenated.
#' @examples
#' r_sqrt <- record(sqrt)
#' r_log <- record(log)
#' a <- as_chronicle(r_log(10))
#' a
#' flatten_record(a)
#' @export
flatten_record <- function(.c) {
  nested_chronicle <- maybe::from_maybe(.c$value, default = NULL)

  if (!is_chronicle(nested_chronicle)) {
    return(.c)
  }

  log_df <- dplyr::bind_rows(nested_chronicle$log_df, .c$log_df) |>
    dplyr::mutate(
      ops_number = dplyr::row_number(),
      lag_outcome = dplyr::lag(outcome, 1)
    )

  list(
    value = nested_chronicle$value,
    log_df = log_df
  ) |>
    structure(class = "chronicle")
}

#' Evaluate a non-chronicle function on a chronicle object.
#' @param .c A chronicle object.
#' @param .f A non-chronicle function.
#' @param ... Further parameters to pass to `.f`.
#' @importFrom maybe from_maybe nothing is_nothing
#' @importFrom dplyr bind_rows mutate row_number lag
#' @return Returns the result of `.f(.c$value)` as a new chronicle object.
#' @examples
#' as_chronicle(3) |> fmap_record(sqrt)
#' @export
fmap_record <- function(.c, .f, ...) {
  f_string <- deparse1(substitute(.f))

  start <- Sys.time()
  pure_f <- purely(.f, strict = 2)
  val <- maybe::from_maybe(.c$value, default = maybe::nothing())
  res_pure <- pure_f(val, ...)
  end <- Sys.time()

  was_successful <- !maybe::is_nothing(res_pure$value)

  log_df_entry <- make_log_df(
    success = was_successful,
    fstring = "fmap_record",
    args = f_string,
    res_pure = res_pure,
    start = start,
    end = end
  )

  log_df <- dplyr::bind_rows(.c$log_df, log_df_entry) |>
    dplyr::mutate(
      ops_number = dplyr::row_number(),
      lag_outcome = dplyr::lag(outcome, 1)
    )

  current_row <- nrow(log_df)
  if (
    !was_successful &&
      current_row > 1 &&
      grepl("NOK!", log_df$lag_outcome[current_row])
  ) {
    log_df$message[current_row] <- "Pipeline failed upstream"
  }

  list(
    value = res_pure$value,
    log_df = log_df
  ) |>
    structure(class = "chronicle")
}
