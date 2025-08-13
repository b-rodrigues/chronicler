library(dplyr)
library(rlang)


a <- catch_cnd(log("10"))

b <- catch_cnd(dplyr::select(mtcars, bm))


dplyr::select(mtcars, bm)

purely(select)(mtcars, bm)


hu <- catch_cnd(filter(mtcars, bm == 1))

str(hu)

hu$parent$message
hu$message

https://gist.github.com/wch/ad8e5ba859f2968a5c2ce33dd8f692c8
pluck_recursive2 <- function(x, name) {
  result <- list()
  
  pluck_r <- function(x, name) {
    x_names <- names(x)
                                        # Need to watch out for unnamed lists
    is_named_list <- !is.null(x_names)

    for(i in seq_along(x)) {
      if (is_named_list && x_names[i] == name) {
        result[[length(result) + 1]] <<- x[[i]]
      } else if (is.list(x[[i]])) {
        pluck_r(x[[i]], name)
      }
    }
  }
  
  pluck_r(x, name)
  
  result
}

pluck_recursive2(hu, "message")

rlang::cnd_message(hu)

# This gives the "correct" error message
(dplyr::select(mtcars, bm))

# but if I save it and then print it, I find something else
ha <- rlang::cnd_message(
               rlang::catch_cnd(
                        dplyr::select(mtcars, bm),
                        class = "error"
                      )
               )
print(ha)

# pluck_recursive2() finds the same thing (you cand find this function here )
# https://gist.github.com/wch/ad8e5ba859f2968a5c2ce33dd8f692c8
source("https://gist.githubusercontent.com/wch/ad8e5ba859f2968a5c2ce33dd8f692c8/raw/646af26c58cdfb39a7aa5a33a8d510c189575561/pluck_recursive.R")
pluck_recursive2(rlang::catch_cnd(
                          dplyr::select(mtcars, bm)
                        ), "message")

purely(filter)(mtcars, bm == 1)

res <- rlang::try_fetch(
                rlang::eval_tidy(.f(...)),
                error = function(err) err,
                warning = function(warn) warn,
                message = function(message) message,
                )


catch_cnd2 <- function (expr, classes = "condition") {
  stopifnot(is_character(classes))
  handlers <- rep_named(classes, list(identity))
  eval_bare(rlang::expr(tryCatch(!!!handlers, {
    force(expr)
  })))
}

catch_cnd2(select(mtcars, am), classes = "error")
he <- catch_cnd2(select(mtcars, bm), classes = c("error", "warning", "message"))

a1 <- tryCatch(dplyr::select(mtcars, bm), 
               error = function(e) e)

a2 <- tryCatch(dplyr::select(mtcars, am), 
               error = function(e) e)

