#' Creates the log_df element of a chronicle
#' @param success Did the operation succeed
#' @param fstring The function call
#' @param args The arguments of the call
#' @param res_pure The result of the purely call
#' @param start Starting time
#' @param end Ending time
#' @param .g Optional. A function to apply to the intermediary results for monitoring purposes. Defaults to returning NA.
#' @return A tibble containing the log.
make_log_df <- function(success,
                        fstring,
                        args,
                        res_pure,
                        start = Sys.time(),
                        end = Sys.time(),
                        .g = (\(x) NA)){

  outcome <- ifelse(success == 1,
                    "✔ Success",
                    "✖ Caution - ERROR")

  tibble::tibble(
            "outcome" = outcome,
            "function" = fstring,
            "arguments" = args,
            "message" = paste0(res_pure$log, collapse = " "),
            "start_time" = start,
            "end_time" = end,
            "run_time" = end - start,
            "g" = list(.g(res_pure$value))
          )

}


#' Reads the log of a chronicle
#' @param .c A chronicle
#' @return Strings containing the log
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
           "✔",
           "✖")

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


#' Print method for chronicle objects
#' @param .c A chronicle
#' @export
print.chronicle <- function(.c, ...){

  if(all(grepl("Success", .c$log_df$outcome))){

    succeed <- "successfully"
    success_symbol <- "✔"

  } else {

    succeed <- "unsuccessfully ✖"
    success_symbol <- "✖"

  }

  cat(paste0(success_symbol, " Value computed ", succeed, ":\n"))
  cat("---------------\n")
  print(.c$value, ...)
  cat("\n")
  cat("---------------\n")
  cat("This is an object of type `chronicle`.\n")
  cat("Retrieve the value of this object with pick(.c, \"value\").\n")
  cat("To read the log of this object, call read_log().\n")
  cat("\n")

}

only_errors <- function(.f, ...){

  rlang::try_fetch(
           rlang::eval_tidy(.f(...)),
           error = function(err) err,
           )

}

errors_and_warnings <- function(.f, ...){

  rlang::try_fetch(
           rlang::eval_tidy(.f(...)),
           error = function(err) err,
           warning = function(warn) warn,
           )
}

errs_warn_mess <- function(.f, ...){

  rlang::try_fetch(
           rlang::eval_tidy(.f(...)),
           error = function(err) err,
           warning = function(warn) warn,
           message = function(message) message,
           )
}

#' Capture all errors, warnings and messages
#' @param .f A function to decorate
#' @param strict Controls if the decorated function should catch only errors (1), errors and warnings (2, the default) or errors, warnings and messages (3)
#' @return A function which returns a list. The first element of the list, $value, is the result of
#' the original function .f applied to its inputs. The second element, $log is NULL in case everything
#' goes well. In case of error/warning/message, $value is NA and $log holds the message.
#' purely() is used by record() to allow the latter to handle errors.
#' @importFrom rlang try_fetch eval_tidy cnd_message
#' @examples
#' purely(log)(10)
#' purely(log)(-10)
#' purely(log, strict = 1)(-10) # This produces a warning, so with strict = 1 nothing gets captured.
#' @export
purely <- function(.f, strict = 2){

  function(..., .log_df = "Log start..."){

    res <- switch(strict,
                  only_errors(.f, ...),
                  errors_and_warnings(.f, ...),
                  errs_warn_mess(.f, ...))

    final_result <- list(
      value = NULL,
      log_df = NULL
    )

    final_result$value <- if(any(c("error", "warning", "message") %in% class(res))){
                             NA
                           } else {
                             res
                           }

    final_result$log_df <- if(any(c("error", "warning", "message") %in% class(res))){
                          rlang::cnd_message(res)
                           } else {
                             NA
                           }

    final_result


  }
}

#' Decorates a function to output objects of type `chronicle`.
#' @param .f A function to decorate
#' @param .g Optional. A function to apply to the intermediary results for monitoring purposes. Defaults
#' to returning NA.
#' @param strict Controls if the decorated function should catch only errors (1), errors and warnings (2, the default) or errors, warnings and messages (3)
#' @return A function which returns objects of type `chronicle`. `chronicle` objects carry several
#' elements: a `value` which is the result of the function evaluated on its inputs and a second
#' object called `log_df`. `log_df` contains logging information, which can be read using
#' `read_log()`. `log_df` is a data frame with
#' colmuns: outcome, function, arguments, message, start_time, end_time, run_time and g.
#' @importFrom rlang enexprs
#' @importFrom tibble tibble
#' @examples
#' record(sqrt)(10)
#' @export
record <- function(.f, .g = (\(x) NA), strict = 2){

  fstring <- deparse1(substitute(.f))

  function(..., .log_df = data.frame()){

    args <- paste0(rlang::enexprs(...), collapse = ",")
    the_function_call <- paste0(fstring, "("  , args, ")")

    start <- Sys.time()
    pure_f <- purely(.f, strict = strict)
    res_pure <- (pure_f(...))
    end <- Sys.time()

    if(all(is.na(res_pure$value))){

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
        .g = .g
      )

    }

    log_df <- rbind(.log_df,
                    log_df)

    list_result <- list(
      value = res_pure$value,
      log_df = log_df
    )


    structure(list_result, class = "chronicle")
  }
}

#' Evaluate a decorated function
#' @param .c A chronicle object (a list of two elements)
#' @param .f A chronicle function to apply to the returning value of .c
#' @param ... Further parameters to pass to .f
#' @return A list with elements .f(.c$value) and concatenated logs.
#' @examples
#' r_sqrt <- record(sqrt)
#' r_exp <- record(exp)
#' 3 |> r_sqrt() |> bind_record(r_exp)
#' @export
bind_record <- function(.c, .f, ...){

  .f(.c$value, ..., .log_df = .c$log_df)

}


#' Evaluate a non-chronicle function on a chronicle object
#' @param .c A chronicle object (a list of two elements)
#' @param .f A non-chronicle function
#' @param ... Further parameters to pass to .f
#' @return Returns the result of .f(.c$value)
#' @examples
#' as_chronicle(3) |> flat_chronicle(sqrt)
#' @export
flat_chronicle <- function(.c, .f, ...){

  res_pure <- list("log" = NA,
                   "value" = NA)

  log_df <- make_log_df(
    success = 1,
    fstring = "flat_chronicle",
    args = NA,
    res_pure = res_pure,
    start = Sys.time(),
    end = Sys.time())

  list(value = .f(.c$value, ...),
       log_df = dplyr::bind_rows(.c$log_df,
                                 log_df)) |>
  structure(class = "chronicle")
}

#' Create a chronicle object
#' @param .x Any object
#' @return Returns a chronicle object with the object as the $value
#' @importFrom tibble tibble
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

  list(value = .x,
       log_df = dplyr::bind_rows(.log_df,
                                 log_df)) |>
  structure(class = "chronicle")
}

#' Pipe a chronicle object to a decorated function
#' @param .c A value returned by record
#' @param .f A chronicle function to apply to the returning value of .c
#' @return A chronicle object.
#' @importFrom stringr str_extract
#' @examples
#' r_sqrt <- record(sqrt)
#' r_exp <- record(exp)
#' 3 |> r_sqrt() %>=% r_exp()
#' @export
`%>=%` <- function(.c, .f, ...) {

  parsed <- parse_function(deparse1(substitute(.f)))

  cmd <- make_command(parsed)
  eval(parse(text = cmd))

}

make_command <- function(parsed_function){

  paste0(".c$value |> ",
         parsed_function$func,
         "(",
         parsed_function$args,
         ".log_df = .c$log_df)")

}

parse_function <- function(.f_string){

  func <- gsub("\\(.*$", "", .f_string)
  args <- stringr::str_extract(.f_string, "\\(.*")
  args <- gsub("^\\(", "", args)
  args <- gsub("\\)$", "", args)
  args <- ifelse(args != "", paste0(args, ", "), "")

 # func <- .f_string[1]
 # args <- ifelse(is.na(.f_string[-1]),
 #                "",
 #                c(paste0(.f_string[-1], collapse = ", "), ", "))

  list("func" = func,
       "args" = args)

}



#' Retrieve an element from a chronicle object
#' @param .c A chronicle object
#' @param .e Element of interest to retrieve, one of "value" or "log"
#' @return The `value` or `log` element of the chronicle object .c
#' @examples
#' r_sqrt <- record(sqrt)
#' r_exp <- record(exp)
#' 3 |> r_sqrt() %>=% r_exp() |> pick("value")
#' @export
pick <- function(.c, .e){

  stopifnot('.e must be either "value", "log_df"' = .e %in% c("value", "log_df"))

  .c[[.e]]

}
