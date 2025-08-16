#' Write a chronicler Data Frame object to a file
#'
#' Saves the contents of a \code{chronicler} object to a CSV or Excel file,
#' including both the dataset and the log of operations. The data is stored in
#' the \code{value} component of the chronicler object, and the log is included
#' as metadata in the output.
#'
#' @param .c A \code{chronicler} object.
#' @param path A single character string specifying the output file path. The
#'   file extension must be either \code{.csv} or \code{.xlsx}.
#' @param row.names Logical, whether to include row names when writing to CSV.
#'   Defaults to \code{FALSE}.
#' @param sep Character. Field separator for CSV output. Defaults to \code{","}.
#' @param ... Additional arguments passed to \code{\link[utils]{write.table}}
#'   when writing CSV.
#'
#' @return Invisibly returns \code{NULL}. The function is called for its side effect of
#'   writing files.
#'
#' @details
#' When writing a CSV file, the first few lines contain the log of operations
#' performed on the data. Users should skip these lines when reading the data
#' back in. When writing an Excel file, two sheets are created: \code{value}
#' containing the dataset, and \code{log} containing the log of operations as a
#' data frame for better readability.
#'
#' @importFrom utils write.table
#'
#' @examples
#' \dontrun{
#' # Assume `c` is a chronicler object
#' write_chronicle_df(c, path = "output.csv")
#' write_chronicle_df(c, path = "output.xlsx")
#' }
#'
#' @export
write_chronicle_df <- function(.c, path, row.names = FALSE, sep = ",", ...) {
  stopifnot("Only provide one path" = length(path) == 1)

  value <- chronicler::unveil(.c, "value")
  stopifnot("Value must be of class data.frame!" = is.data.frame(value))

  ext <- regmatches(
    path,
    regexpr("\\.([0-9a-z]+)(?=[?#])|(\\.)(?:[\\w]+)$", path, perl = TRUE)
  )

  if (
    any(ext %in% c(".xlsx", ".xls")) &&
      !requireNamespace("openxlsx", quietly = TRUE)
  ) {
    stop(
      sprintf(
        "The 'openxlsx' package is required to write %s files.\n  Please install it to use this feature.",
        ext
      )
    )
  }
  stopifnot(
    "write_chronicle() can only save data as either .csv or .xlsx. Change the extension of the output." = any(
      c(".csv", ".xlsx") %in% ext
    )
  )

  log <- chronicler::read_log(.c)

  if (ext == ".csv") {
    logcsv <- c(
      paste0(
        "This first ",
        length(log) + 2,
        " lines of this .csv file constitute a log."
      ),
      paste0("Skip the first ", length(log) + 2, " lines to read in the data."),
      log
    )

    write(logcsv, file = path)
    suppressWarnings(
      write.table(
        value,
        file = path,
        sep = sep,
        append = TRUE,
        row.names = row.names,
        ...
      )
    )
  } else {
    # Convert log to a data frame for cleaner Excel output
    log_df <- data.frame(
      Entry = c(
        "This sheet contains a log of the operations used to create the dataset in the 'value' sheet.",
        log
      ),
      stringsAsFactors = FALSE
    )

    xlsx_output <- list(
      value = value,
      log = log_df
    )

    openxlsx::write.xlsx(xlsx_output, file = path)
  }
}
