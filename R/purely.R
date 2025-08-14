#' Capture all errors, warnings and messages.
#' @param .f A function to decorate.
#' @param strict Controls if the decorated function should catch only errors (1), errors and
#'   warnings (2, the default) or errors, warnings and messages (3).
#' @return A function which returns a list. The first element of the list, `$value`,
#' is the result of the original function `.f` applied to its inputs. The second element, `$log` is
#' `NULL` in case everything goes well. In case of error/warning/message, `$value` is NA and `$log`
#' holds the message. `purely()` is used by `record()` to allow the latter to handle errors.
#' @importFrom rlang try_fetch eval_tidy cnd_message
#' @importFrom maybe just nothing is_nothing
#' @examples
#' purely(log)(10)
#' purely(log)(-10)
#' purely(log, strict = 1)(-10) # This produces a warning, so with strict = 1 nothing gets captured.
#' @export
purely <- function(.f, strict = 2) {
  force(.f)

  function(.value, ..., .log_df = "Log start...") {
    if (maybe::is_nothing(.value)) {
      return(list(
        value = maybe::nothing(),
        log_df = "A `Nothing` was given as input."
      ))
    }

    handler <- function(cnd) cnd
    res <- switch(
      as.integer(strict),
      tryCatch(.f(.value, ...), error = handler),
      tryCatch(.f(.value, ...), error = handler, warning = handler),
      tryCatch(
        .f(.value, ...),
        error = handler,
        warning = handler,
        message = handler
      ),
      stop("`strict` must be 1, 2, or 3.", call. = FALSE)
    )

    is_condition <- inherits(res, "condition")

    list(
      value = if (is_condition) maybe::nothing() else maybe::just(res),
      log_df = if (is_condition) rlang::cnd_message(res) else NA_character_
    )
  }
}
