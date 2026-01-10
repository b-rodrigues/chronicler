# Write a chronicler Data Frame object to a file

Saves the contents of a `chronicler` object to a CSV or Excel file,
including both the dataset and the log of operations. The data is stored
in the `value` component of the chronicler object, and the log is
included as metadata in the output.

## Usage

``` r
write_chronicle_df(.c, path, row.names = FALSE, sep = ",", ...)
```

## Arguments

- .c:

  A `chronicler` object.

- path:

  A single character string specifying the output file path. The file
  extension must be either `.csv` or `.xlsx`.

- row.names:

  Logical, whether to include row names when writing to CSV. Defaults to
  `FALSE`.

- sep:

  Character. Field separator for CSV output. Defaults to `","`.

- ...:

  Additional arguments passed to
  [`write.table`](https://rdrr.io/r/utils/write.table.html) when writing
  CSV.

## Value

Invisibly returns `NULL`. The function is called for its side effect of
writing files.

## Details

When writing a CSV file, the first few lines contain the log of
operations performed on the data. Users should skip these lines when
reading the data back in. When writing an Excel file, two sheets are
created: `value` containing the dataset, and `log` containing the log of
operations as a data frame for better readability.

## Examples

``` r
if (FALSE) { # \dontrun{
# Assume `c` is a chronicler object
write_chronicle_df(c, path = "output.csv")
write_chronicle_df(c, path = "output.xlsx")
} # }
```
