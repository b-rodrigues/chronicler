#' Coerce a chronicle object to a data.frame
#'
#' @description
#' This is an S3 method that allows for the easy coercion of a `chronicle` object
#' into a standard `data.frame`. It automatically unwraps the object by calling
#' `unveil(.c, "value")` and then attempts to convert the result into a data frame.
#'
#' @param x A `chronicle` object.
#' @param row.names `NULL` or a character vector giving the row names for the
#'   data frame.
#' @param optional logical. If `TRUE`, setting row names and converting column
#'   names is optional.
#' @param ... Additional arguments to be passed to or from other methods.
#'
#' @return A `data.frame` if the `value` inside the chronicle object is a
#'   `data.frame` or can be successfully coerced into one.
#'
#' @details
#' The function will produce an error if the underlying `value` of the chronicle
#' object cannot be coerced to a data frame by the base `as.data.frame()` method.
#' The error message will be specific, indicating the class of the object that
#' caused the failure.
#'
#' @export
#' @examples
#' library(dplyr)
#'
#' # --- Successful Example ---
#'
#' # Create a chronicle object whose value is a data frame
#' starwars_chronicle <- starwars %>%
#'   record(filter)(species == "Human") %>%
#'   bind_record(record(select), name, height, mass)
#'
#' # Now, you can use as.data.frame() directly on the chronicle object
#' sw_df <- as.data.frame(starwars_chronicle)
#'
#' class(sw_df)
#' head(sw_df)
#'
#'
#' # --- Error Example ---
#'
#' # Create a chronicle object whose value is a number
#' numeric_chronicle <- record(sqrt)(100)
#'
#' # This will fail with a specific error message because a number
#' # cannot be turned into a data frame.
#' try(as.data.frame(numeric_chronicle))
#'
as.data.frame.chronicle <- function(
  x,
  row.names = NULL,
  optional = FALSE,
  ...
) {
  # 1. Safely unveil the value from the chronicle object
  value <- unveil(x, "value")

  # 2. Delegate to base as.data.frame() (ensures tibbles/grouped_dfs are
  #    coerced to base data.frame and row.names/optional/... are respected)
  tryCatch(
    {
      # Attempt to coerce using the base S3 method on the extracted value
      out <- as.data.frame(
        value,
        row.names = row.names,
        optional = optional,
        ...
      )
      if (!is.null(row.names)) {
        row.names(out) <- row.names
      }
      out
    },
    error = function(e) {
      # If the coercion fails, stop with a custom, more informative error.
      stop(
        sprintf(
          "The 'value' inside this chronicle object (class: %s) cannot be coerced to a data.frame.\n  Original error: %s",
          class(value)[1], # Get the class of the problematic object
          e$message # Include the original error message for context
        ),
        call. = FALSE # Suppress the call stack from appearing in the error
      )
    }
  )
}
