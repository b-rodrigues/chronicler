# WARNING - Generated by {fusen} from dev/flat_chronicle.Rmd: do not edit by hand

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
#' @importFrom dplyr mutate lag row_number select
#' @importFrom maybe is_nothing
#' @importFrom rlang enexprs
#' @importFrom tibble tibble
#' @importFrom utils tail
#' @examples
#' record(sqrt)(10)
#' @export
record <- function(.f, .g = (\(x) NA), strict = 2, diff = "none"){

  fstring <- deparse1(substitute(.f))

  function(.value, ..., .log_df = data.frame()){

    args <- paste0(rlang::enexprs(...), collapse = ",")

    start <- Sys.time()
    pure_f <- purely(.f, strict = strict)
    res_pure <- (pure_f(.value, ...))
    end <- Sys.time()

    input <- .value
    output <- maybe::from_maybe(res_pure$value, default = maybe::nothing())
    diff_obj <- switch(diff,
                       "none" = NULL,
                       "summary" = diffobj::summary(diffobj::diffObj(input, output)),
                       "full" = diffobj::diffObj(input, output)
                       )

    if(maybe::is_nothing(res_pure$value)){

      log_df <- make_log_df(
        success = 0,
        fstring = fstring,
        args = args,
        res_pure = res_pure,
        start = start,
        end = end,
        .g = .g
      )

    } else {

      log_df <- make_log_df(
        success = 1,
        fstring = fstring,
        args = args,
        res_pure = res_pure,
        start = start,
        end = end,
        .g = .g,
        diff_obj = diff_obj
      )

    }

    # Columns ops_number and lag_outcome
    # help with writing meaningful error message
    log_df <- dplyr::mutate(
          rbind(.log_df,
                log_df),
          ops_number = dplyr::row_number(),
          lag_outcome = dplyr::lag(outcome, 1)
          )

    # correct error message for first operation
    # if there's only one ops which failed, we need to keep the error message
    # if some ops where successful, but then one fails, we need to keep its error message
    # the following failures can then all have a generic message
    if(maybe::is_nothing(res_pure$value)
       & tail(log_df, 1)$ops_number == 1){
      log_df$message <- paste0(res_pure$log_df, collapse = " ")
    } else if (maybe::is_nothing(res_pure$value)
               & !grepl("Success", tail(log_df, 1)$lag_outcome)
               & tail(log_df, 1)$ops_number > 1){
      log_df[nrow(log_df), ]$message <- "Pipeline failed upstream"
    }

    list_result <- list(
      value = res_pure$value,
      log_df = log_df
    )

    structure(list_result, class = "chronicle")

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
record_many <- function(list_funcs, .g = (function(x) NA), strict = 2, diff = "none"){

  sanitized_list <- stringr::str_remove_all(list_funcs, "(.*?)\\:")

  clipr::write_clip(
           paste0("r_", sanitized_list, " <- ", "record(",
                  list_funcs,
                  ", .g = ",
                  deparse(substitute(.g)),
                  ", strict = ",
                  strict,
                  ", diff = ",
                  paste0("\"", diff, "\""),
                  ")")
           )

  message("Code copied to clipboard. You can now paste it into your text editor.")

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
make_log_df <- function(ops_number = 1,
                        success,
                        fstring,
                        args,
                        res_pure,
                        start = Sys.time(),
                        end = Sys.time(),
                        .g = (\(x) NA),
                        diff_obj = NULL){

  outcome <- ifelse(success == 1,
                    "OK! Success",
                    "NOK! Caution - ERROR")

  tibble::tibble(
            "ops_number" = ops_number,
            "outcome" = outcome,
            "function" = fstring,
            "arguments" = args,
            "message" = paste0(res_pure$log_df, collapse = " "),
            "start_time" = start,
            "end_time" = end,
            "run_time" = end - start,
            "g" = list(.g(maybe::from_maybe(res_pure$value,
                                            default = maybe::nothing()))),
            "diff_obj" = list(diff_obj),
            "lag_outcome" = NA
          )

}

#' Reads the log of a chronicle.
#' @param .c A chronicle object.
#' @return The log of the object.
#' @examples
#' \dontrun{
#' read_log(chronicle_object)
#' }
#' @export
read_log <- function(.c){

  log_df <- .c$log_df

  make_func_call <- function(log_df, i){

    paste0(paste0(log_df[i, c("function", "arguments")],
                  collapse = "("),
           ")")

  }

  is_success <- function(log_df, i){

    ifelse(grepl("Success", log_df$outcome[i]),
           "successfully",
           paste0("unsuccessfully with following exception: ", log_df$message[i]))

  }

  success_symbol <- function(log_df, i){

    ifelse(grepl("Success", log_df$outcome[i]),
           "OK!",
           "NOK!")

  }

  make_sentence <- function(log_df, i){

    paste(success_symbol(log_df, i),
          make_func_call(log_df, i),
          "ran",
          is_success(log_df, i),
          "at",
          log_df$start_time[i])

  }

  total_runtime <- function(log_df){

    total_time <- log_df$run_time

    unit <- attr(total_time, "units")

    paste(as.numeric(sum(log_df$run_time)), unit)

  }


  sentences <- vector(length = nrow(log_df))

  for(i in 1:nrow(log_df)){

  sentences[i] <-  make_sentence(log_df, i)

  }

  c("Complete log:", sentences, paste("Total running time:", total_runtime(log_df)))

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
print.chronicle <- function(x, ...){

  if(all(grepl("Success", x$log_df$outcome))){

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
  cat("Retrieve the value of this object with pick(.c, \"value\").\n")
  cat("To read the log of this object, call read_log(.c).\n")
  cat("\n")

}

#' Checks whether an object is of class "chronicle"
#' @param .x An object to test.
#' @export
#' @return TRUE if .x is of class "chronicle", FALSE if not.
is_chronicle <- function(.x) {
  identical(class(.x), "chronicle")
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
as_chronicle <- function(.x, .log_df = data.frame()){

  res_pure <- list("log" = NA,
                   "value" = NA)

  log_df <- make_log_df(
    success = 1,
    fstring = "as_chronicle",
    args = NA,
    res_pure = res_pure,
    start = Sys.time(),
    end = Sys.time())

  list(value = maybe::just(.x),
       log_df = dplyr::bind_rows(.log_df,
                                 log_df)) |>
  structure(class = "chronicle")

}


#' Retrieve an element from a chronicle object.
#' @param .c A chronicle object.
#' @param .e Element of interest to retrieve, one of "value" or "log_df".
#' @return The `value` or `log_df` element of the chronicle object .c.
#' @importFrom maybe from_maybe nothing
#' @examples
#' r_sqrt <- record(sqrt)
#' r_exp <- record(exp)
#' 3 |> r_sqrt() %>=% r_exp() |> pick("value")
#' @export
pick <- function(.c, .e){

  stopifnot('.e must be either "value", "log_df"' = .e %in% c("value", "log_df"))

  if(.e == "value"){
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
check_g <- function(.c, columns = c("ops_number", "function")){

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
check_diff <- function(.c, columns = c("ops_number", "function")){

  as.data.frame(.c$log_df[, c(columns, "diff_obj")])

}

