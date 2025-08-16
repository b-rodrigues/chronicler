#' Create a ggplot object to display an error message.
#' @noRd
#' @importFrom ggplot2 ggplot aes annotate theme_void theme element_rect
create_error_plot <- function(error_message) {
  background_color <- "#FFDDDD"
  error_text <- strwrap(error_message)

  ggplot2::ggplot() +
    ggplot2::aes(x = 0, y = 0) +
    ggplot2::annotate(
      "text",
      x = 0,
      y = 0,
      label = error_text,
      color = "black",
      size = 4
    ) +
    ggplot2::theme_void() +
    ggplot2::theme(
      plot.background = ggplot2::element_rect(
        fill = background_color,
        color = NA
      ),
      panel.background = ggplot2::element_rect(
        fill = background_color,
        color = NA
      )
    )
}

#' Record a ggplot expression
#'
#' @description
#' `record_ggplot` captures a complete `{ggplot2}` expression, evaluates it, and
#' creates a `chronicle` object. It uses a robust `tryCatch` and `withCallingHandlers`
#' pattern to reliably capture errors, warnings, and messages.
#'
#' To trigger all conditions, including rendering-time warnings and messages, it
#' forces a full render of the plot. This is achieved safely by opening a null
#' graphics device (`pdf(NULL)`), scheduling its closure with `on.exit(dev.off())`,
#' and then printing the plot. This guarantees that the temporary device is always
#' closed, even if an error occurs, preventing any side effects on the user's
#' active graphics session.
#'
#' @param ggplot_expression The entire `{ggplot2}` expression to be recorded.
#' @param strict An optional integer argument controlling what is treated as a failure:
#'   * `1`: Catches only errors.
#'   * `2`: Catches errors and warnings (the default).
#'   * `3`: Catches errors, warnings, and messages.
#' @return A `chronicle` object. When printed, it will display the plot if successful
#'   or an error plot if it failed.
#' @importFrom rlang enquo eval_tidy quo_text cnd_message abort
#' @importFrom grDevices pdf dev.off
#' @export
record_ggplot <- function(ggplot_expression, strict = 2) {
  ggplot_expr_quo <- rlang::enquo(ggplot_expression)
  fstring <- rlang::quo_text(ggplot_expr_quo)
  start <- Sys.time()

  res <- tryCatch(
    withCallingHandlers(
      {
        # First, evaluate the expression to create the ggplot object.
        ggplot_obj <- rlang::eval_tidy(ggplot_expr_quo)

        # To force a full render, we print the plot to a temporary, null
        # graphics device. This device discards all output.
        grDevices::pdf(NULL)

        # CRUCIALLY, we schedule the device to be closed when the function
        # exits, for any reason (success, error, etc.). This prevents any
        # corruption of the user's graphics state.
        on.exit(grDevices::dev.off())

        # Now, print the plot. This action will trigger all rendering-time
        # warnings and messages, which our handlers will catch.
        print(ggplot_obj)

        # If we got here, the render was successful. Return the original,
        # untouched ggplot object so it can be printed later.
        ggplot_obj
      },
      warning = function(w) {
        if (strict >= 2) {
          rlang::abort("promoted_warning", parent = w)
        }
      },
      message = function(m) {
        if (strict >= 3) {
          rlang::abort("promoted_message", parent = m)
        }
      }
    ),
    # This catches both original errors and our promoted conditions.
    error = function(e) e
  )
  end <- Sys.time()

  was_successful <- !inherits(res, "condition")
  final_value <- NULL
  log_message <- NA_character_

  if (was_successful) {
    # On success, the value is the original ggplot object.
    final_value <- maybe::just(res)
  } else {
    # On failure, get the underlying condition and create the error plot.
    original_cnd <- if (!is.null(res$parent)) res$parent else res
    log_message <- rlang::cnd_message(original_cnd)
    error_plot <- create_error_plot(log_message)
    final_value <- maybe::just(error_plot)
  }

  res_for_log <- list(value = final_value, log_df = log_message)

  log_df <- make_log_df(
    success = as.integer(was_successful),
    fstring = fstring,
    args = "",
    res_pure = res_for_log,
    start = start,
    end = end
  )

  list(
    value = final_value,
    log_df = log_df
  ) |>
    structure(class = "chronicle")
}
