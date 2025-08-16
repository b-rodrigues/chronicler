#' Decorates a function to output objects of type `chronicle`.
#' @param .f A function to decorate.
#' @param .g Optional. A function to apply to the intermediary results for monitoring purposes. Defaults to returning NA.
#' @param strict Controls if the decorated function should catch only errors (1), errors and warnings (2, the default) or errors, warnings and messages (3).
#' @param diff Whether to show the diff between the input and the output ("full"), just a summary of the diff ("summary"), or none ("none", the default)
#' @return A function which returns objects of type `chronicle`. `chronicle` objects carry several
#' elements: a `value` which is the result of the function evaluated on its inputs and a second
#' object called `log_df`. `log_df` contains logging information, which can be read using
#' `read_log()`. `log_df` is a data frame with columns: outcome, function, arguments, message, start_time, end_time, run_time, g and diff_obj.
#' @details
#' To chain multiple decorated function, use `bind_record()` or `%>=%`.
#' If the `diff` parameter is set to "full", `diffobj::diffObj()`
#' (or `diffobj::summary(diffobj::diffObj()`, if diff is set to "summary")
#' gets used to provide the diff between the input and the output.
#' This diff can be found in the `log_df` element of the result, and can be
#' viewed using `check_diff()`.
#' @importFrom diffobj diffObj summary
#' @importFrom dplyr mutate lag row_number bind_rows
#' @importFrom maybe is_nothing from_maybe nothing just
#' @importFrom rlang enexprs
#' @importFrom tibble tibble
#' @examples
#' record(sqrt)(10)
#' record(sqrt)(x = 10)
#' @export
record <- function(.f, .g = (\(x) NA), strict = 2, diff = "none") {
  force(.f)
  force(.g)
  fstring <- deparse1(substitute(.f))

  function(.value, ..., .log_df = data.frame()) {
    # Capture the call and arguments
    other_args_exprs <- rlang::enexprs(...)

    # Determine the main data value and other arguments based on call type
    if (missing(.value)) {
      # This is a direct call, not from a pipe.
      # e.g., r_sqrt(10) or r_select(df, col)
      if (length(other_args_exprs) == 0) {
        stop("At least one argument must be provided.", call. = FALSE)
      }
      # The first argument in ... is the data
      data_val <- eval(other_args_exprs[[1]], envir = parent.frame())
      func_args <- other_args_exprs[-1]
      log_args_exprs <- other_args_exprs
    } else {
      # This is a piped call, either from `|>` or `%>=%` (bind_record)
      # .value is the data from the pipe.
      data_val <- .value
      func_args <- other_args_exprs
      # For logging, we need to represent the full call.
      # deparse(substitute(.value)) will give the name of the variable if it came from a pipe.
      # For bind_record, it might be complex, so we just represent it as the data itself.
      # A simple deparse is sufficient for most logging cases.
      log_args_exprs <- c(list(substitute(.value)), other_args_exprs)
    }

    # For logging, deparse the expressions to get a string representation
    # For direct calls, this is perfect. For piped calls, it's an approximation.
    mc <- match.call()
    mc$.log_df <- NULL
    mc[[1]] <- NULL
    args <- paste0(sapply(mc, deparse), collapse = ", ")

    start <- Sys.time()
    pure_f <- purely(.f, strict = strict)
    # We pass the evaluated data_val and the unevaluated other args to pure_f
    res_pure <- do.call(pure_f, c(list(data_val), func_args))
    end <- Sys.time()

    input <- data_val
    output <- maybe::from_maybe(res_pure$value, default = maybe::nothing())

    diff_obj <- switch(
      diff,
      "none" = NULL,
      "summary" = diffobj::summary(diffobj::diffObj(input, output)),
      "full" = diffobj::diffObj(input, output),
      stop('`diff` must be one of "none", "summary", "full".', call. = FALSE)
    )

    was_successful <- !maybe::is_nothing(res_pure$value)

    log_df_entry <- make_log_df(
      success = was_successful,
      fstring = fstring,
      args = args,
      res_pure = res_pure,
      start = start,
      end = end,
      .g = .g,
      diff_obj = diff_obj
    )

    log_df <- dplyr::bind_rows(.log_df, log_df_entry) |>
      dplyr::mutate(
        ops_number = dplyr::row_number(),
        lag_outcome = dplyr::lag(outcome, 1)
      )

    # Correct the message for chained failures
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
}


#' Decorate a list of functions
#' @details
#' Functions must be entered as strings of the form "function" or "package::function".
#' The code gets generated and copied into the clipboard. The code can then be pasted
#' into the text editor. On GNU/Linux systems, you might get the following error
#' message on first use: "Error in : Clipboard on X11 requires that the DISPLAY envvar be configured".
#' This is an error message from `clipr::write_clip()`, used by `record_many()` to put
#' the generated code into the system's clipboard.
#' To solve this issue, run `echo $DISPLAY` in the system's shell.
#' This command should return a string like ":0". Take note of this string.
#' In your .Rprofile, put the following command: Sys.setenv(DISPLAY = ":0") and restart
#' the R session. `record_many()` should now work.
#' @param list_funcs A list of function names, as strings.
#' @param .g Optional. Defaults to a function which returns NA.
#' @param strict Controls if the decorated function should catch only errors (1), errors and warnings (2, the default) or errors, warnings and messages (3).
#' @param diff Whether to show the diff between the input and the output ("full"), just a summary of the diff ("summary"), or none ("none", the default)
#' @return Puts a string into the systems clipboard.
#' @importFrom stringr str_remove_all
#' @importFrom clipr write_clip
#' @export
#' @examples
#' \dontrun{
#' list_funcs <- list("exp", "dplyr::select", "exp")
#' record_many(list_funcs)
#' }
record_many <- function(
  list_funcs,
  .g = (function(x) NA),
  strict = 2,
  diff = "none"
) {
  sanitized_list <- stringr::str_remove_all(list_funcs, "(.*?)\\:")

  clipr::write_clip(
    paste0(
      "r_",
      sanitized_list,
      " <- ",
      "record(",
      list_funcs,
      ", .g = ",
      deparse(substitute(.g)),
      ", strict = ",
      strict,
      ", diff = ",
      paste0("\"", diff, "\""),
      ")"
    )
  )

  message(
    "Code copied to clipboard. You can now paste it into your text editor."
  )
}


#' Creates the log_df element of a chronicle object.
#' @param ops_number Tracks the number of the operation in a chain of operations.
#' @param success Did the operation succeed?
#' @param fstring The function call.
#' @param args The arguments of the call.
#' @param res_pure The result of the purely call.
#' @param start Starting time.
#' @param end Ending time.
#' @param .g Optional. A function to apply to the intermediary results for monitoring purposes. Defaults to returning NA.
#' @param diff_obj Optional. Output of the `diff` parameter in `record()`.
#' @importFrom tibble tibble
#' @importFrom maybe from_maybe nothing
#' @return A tibble containing the log.
#' @noRd
make_log_df <- function(
  ops_number = 1,
  success,
  fstring,
  args,
  res_pure,
  start = Sys.time(),
  end = Sys.time(),
  .g = (\(x) NA),
  diff_obj = NULL
) {
  ok <- isTRUE(success) || identical(success, 1L)
  outcome <- if (ok) "OK! Success" else "NOK! Caution - ERROR"

  msg <- res_pure$log_df
  if (is.null(msg) || length(msg) == 0) {
    msg <- NA_character_
  }
  msg <- paste0(msg, collapse = " ")

  tibble::tibble(
    ops_number = ops_number,
    outcome = outcome,
    "function" = fstring,
    arguments = args,
    message = msg,
    start_time = start,
    end_time = end,
    run_time = end - start,
    g = list(.g(maybe::from_maybe(
      res_pure$value,
      default = maybe::nothing()
    ))),
    diff_obj = list(diff_obj),
    lag_outcome = NA_character_
  )
}


#' Read and display the log of a chronicle
#'
#' @description
#' `read_log()` provides different human-readable views of the log information
#' stored in a `chronicle` object. It can show a pretty, narrative-style summary,
#' a tabular summary suitable for inspection or debugging, or a compact
#' error-focused report.
#'
#' @param .c A chronicle object.
#' @param style A string indicating the display style. One of:
#'   * `"pretty"`: a short, human-friendly log with OK/NOK status, function names,
#'   timestamps, and runtimes.
#'   * `"table"`: a tabular summary of the log as a data frame, including
#'   function names, status, runtime, and messages.
#'   * `"errors-only"`: a minimal report. If all steps succeed, only a single
#'   success message is shown. If any step fails, only the failures are listed.
#'
#' @return
#' * If `style = "pretty"`: a character vector of sentences.
#' * If `style = "table"`: a data frame summarising the log (with an attribute
#'   `"total_runtime_secs"` storing the total runtime in seconds).
#' * If `style = "errors-only"`: a character string if all succeeded, or a
#'   character vector listing only the failed steps.
#'
#' @examples
#' r_select <- record(dplyr::select)
#' r_group_by <- record(dplyr::group_by)
#' r_summarise <- record(dplyr::summarise)
#'
#' output <- dplyr::starwars %>%
#'   r_select(height, mass, species, sex) %>%
#'   bind_record(r_group_by, species, sex) %>%
#'   bind_record(r_summarise, mass = mean(mass, na.rm = TRUE))
#'
#' read_log(output, style = "pretty")
#' read_log(output, style = "table")
#' read_log(output, style = "errors-only")
#'
#' @export
read_log <- function(.c, style = c("pretty", "table", "errors-only")) {
  style <- match.arg(style)
  log_df <- .c$log_df

  # Status text (no emojis)
  status_symbol <- ifelse(grepl("Success", log_df$outcome), "OK", "NOK")

  # Total runtime as seconds
  total_runtime <- sum(log_df$run_time)
  units(total_runtime) <- "secs"
  total_secs <- as.numeric(total_runtime, units = "secs")

  # Access the 'function' column safely
  fn_col <- log_df[["function"]]

  if (style == "pretty") {
    lines <- sprintf(
      "%s `%s` at %s (%.3fs)",
      status_symbol,
      fn_col,
      format(log_df$start_time, "%H:%M:%S"),
      as.numeric(log_df$run_time, units = "secs")
    )
    return(c(lines, paste("Total:", sprintf("%.3f", total_secs), "secs")))
  }

  if (style == "table") {
    df <- data.frame(
      step = seq_len(nrow(log_df)),
      func = fn_col,
      status = status_symbol,
      runtime = round(as.numeric(log_df$run_time, units = "secs"), 3),
      message = log_df$message,
      stringsAsFactors = FALSE
    )
    attr(df, "total_runtime_secs") <- total_secs
    return(df)
  }

  if (style == "errors-only") {
    errors <- log_df[!grepl("Success", log_df$outcome), , drop = FALSE]

    # Drop the "Pipeline failed upstream" noise
    errors <- errors[
      errors$message != "Pipeline failed upstream",
      ,
      drop = FALSE
    ]

    if (nrow(errors) == 0) {
      return(paste(
        "Pipeline ran",
        nrow(log_df),
        "steps successfully in",
        sprintf("%.3f", total_secs),
        "secs"
      ))
    } else {
      lines <- sprintf(
        "NOK `%s` failed: %s (at %s)",
        errors[["function"]],
        errors$message,
        format(errors$start_time, "%H:%M:%S")
      )
      return(c(lines, paste("Total:", sprintf("%.3f", total_secs), "secs")))
    }
  }
}


#' Print method for chronicle objects.
#' @param x A chronicle object.
#' @param ... Unused.
#' @return No return value, called for side effects (printing the object on screen).
#' @details
#' `chronicle` object are, at their core, lists with the following elements:
#' * "$value": a an object of type `maybe` containing the result of the computation (see the "Maybe monad" vignette for more details on `maybe`s).
#' * "$log_df": a `data.frame` object containing the printed object’s log information.
#'
#' `print.chronicle()` prints the object on screen and shows:
#' * the value using its `print()` method (for example, if the value is a data.frame, `print.data.frame()` will be used)
#' * a message indicating to the user how to recuperate the value inside the `chronicle` object and how to read the object’s log
#' @export
print.chronicle <- function(x, ...) {
  if (all(grepl("Success", x$log_df$outcome))) {
    succeed <- "successfully"
    success_symbol <- "OK!"
  } else {
    succeed <- "unsuccessfully"
    success_symbol <- "NOK!"
  }

  cat(paste0(success_symbol, " Value computed ", succeed, ":\n"))
  cat("---------------\n")
  print(x$value, ...)
  cat("\n")
  cat("---------------\n")
  cat("This is an object of type `chronicle`.\n")
  cat("Retrieve the value of this object with unveil(.c, \"value\").\n")
  cat("To read the log of this object, call read_log(.c).\n")
  cat("\n")
}

#' Checks whether an object is of class "chronicle"
#' @param .x An object to test.
#' @export
#' @return TRUE if .x is of class "chronicle", FALSE if not.
is_chronicle <- function(.x) {
  inherits(.x, "chronicle")
}

#' Coerce an object to a chronicle object.
#' @param .x Any object.
#' @param .log_df Used internally, the user does need to interact with it. Defaults to an empty data frame.
#' @return Returns a chronicle object with the object as the $value.
#' @importFrom tibble tibble
#' @importFrom dplyr bind_rows
#' @importFrom maybe just
#' @examples
#' as_chronicle(3)
#' @export
as_chronicle <- function(.x, .log_df = data.frame()) {
  # Match the shape expected by make_log_df()
  res_pure <- list(log_df = NA_character_, value = NA)

  log_df <- make_log_df(
    success = TRUE,
    fstring = "as_chronicle",
    args = NA_character_,
    res_pure = res_pure,
    start = Sys.time(),
    end = Sys.time()
  )

  list(value = maybe::just(.x), log_df = dplyr::bind_rows(.log_df, log_df)) |>
    structure(class = "chronicle")
}


#' Retrieve an element from a chronicle object.
#' @param .c A chronicle object.
#' @param .e Element of interest to retrieve, one of "value" (default) or "log_df".
#' @return The `value` or `log_df` element of the chronicle object .c.
#' @importFrom maybe from_maybe nothing
#' @examples
#' r_sqrt <- record(sqrt)
#' r_exp <- record(exp)
#' 3 |> r_sqrt() %>=% r_exp() |> unveil("value")
#' @export
unveil <- function(.c, .e = "value") {
  if (!is_chronicle(.c)) {
    stop("`.c` must be a chronicle object.")
  }

  stopifnot(
    '.e must be either "value" or "log_df"' = .e %in% c("value", "log_df")
  )

  if (.e == "value") {
    maybe::from_maybe(.c[[.e]], default = maybe::nothing())
  } else {
    .c[[.e]]
  }
}


#' Check the output of the .g function
#' @details
#' `.g` is an option argument to the `record()` function. Providing this optional
#' function allows you, at each step of a pipeline, to monitor interesting characteristics
#' of the `value` object. See the package's Readme file for an example with data frames.
#' @param .c A chronicle object.
#' @param columns Columns to select for the output. Defaults to c("ops_number", "function").
#' @return A data.frame with the selected columns and column "g".
#' @examples
#' r_subset <- record(subset, .g = dim)
#' result <- r_subset(mtcars, select = am)
#' check_g(result)
#' @export
check_g <- function(.c, columns = c("ops_number", "function")) {
  as.data.frame(.c$log_df[, c(columns, "g")])
}

#' Check the output of the diff column
#' @details
#' `diff` is an option argument to the `record()` function. When `diff` = "full",
#' a diff of the input and output of the decorated function gets saved, and if
#' `diff` = "summary" only a summary of the diff is saved.
#' @param .c A chronicle object.
#' @param columns Columns to select for the output. Defaults to c("ops_number", "function").
#' @return A data.frame with the selected columns and column "diff_obj".
#' @examples
#' r_subset <- record(subset, diff = "full")
#' result <- r_subset(mtcars, select = am)
#' check_diff(result) # <- this is the data frame listing the operations and the accompanying diffs
#' check_diff(result)$diff_obj # <- actually look at the diffs
#' @export
check_diff <- function(.c, columns = c("ops_number", "function")) {
  as.data.frame(.c$log_df[, c(columns, "diff_obj")])
}
