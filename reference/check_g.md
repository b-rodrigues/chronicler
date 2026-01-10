# Check the output of the .g function

Check the output of the .g function

## Usage

``` r
check_g(.c, columns = c("ops_number", "function"))
```

## Arguments

- .c:

  A chronicle object.

- columns:

  Columns to select for the output. Defaults to c("ops_number",
  "function").

## Value

A data.frame with the selected columns and column "g".

## Details

`.g` is an option argument to the
[`record()`](https://b-rodrigues.github.io/chronicler/reference/record.md)
function. Providing this optional function allows you, at each step of a
pipeline, to monitor interesting characteristics of the `value` object.
See the package's Readme file for an example with data frames.

## Examples

``` r
r_subset <- record(subset, .g = dim)
result <- r_subset(mtcars, select = am)
check_g(result)
#>   ops_number function     g
#> 1          1   subset 32, 1
```
