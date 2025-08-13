#' Pipe a chronicle object to a decorated function.
#' @param .c A value returned by record.
#' @param .f A chronicle function to apply to the returning value of .c.
#' @return A chronicle object.
#' @importFrom rlang enquo quo_get_expr quo_get_env call_match call2 eval_tidy
#' @importFrom maybe from_maybe nothing
#' @examples
#' r_sqrt <- record(sqrt)
#' r_exp <- record(exp)
#' 3 |> r_sqrt() %>=% r_exp()
#' @export
`%>=%` <- function(.c, .f) {
  # Capture the right-hand side expression and its environment
  f_quo <- rlang::enquo(.f)
  f_exp <- rlang::quo_get_expr(f_quo)
  f_env <- rlang::quo_get_env(f_quo)

  # Extract the function name and get the function object
  f_chr <- deparse(f_exp[[1]])
  f <- get(f_chr, envir = f_env)

  # Match the provided call to the function's formal arguments
  q_ex_std <- rlang::call_match(call = f_exp, fn = f)
  expr_ls <- as.list(q_ex_std)

  # We set the name of the .value argument to empty to avoid it being matched
  # multiple times when we construct the new call with `call2`.
  # The .value is passed explicitly in `call2`.
  names(expr_ls)[names(expr_ls) == ".value"] <- ""

  # Evaluate the function call with the value from the chronicle object
  # and the accumulated log.
  rlang::eval_tidy(rlang::call2(
    f,
    .value = maybe::from_maybe(.c$value, default = maybe::nothing()),
    !!!expr_ls[-1],
    .log_df = .c$log_df
  ))
}
