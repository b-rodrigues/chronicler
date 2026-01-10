# Coerce a chronicle object to a data.frame

This is an S3 method that allows for the easy coercion of a `chronicle`
object into a standard `data.frame`. It automatically unwraps the object
by calling `unveil(.c, "value")` and then attempts to convert the result
into a data frame.

## Usage

``` r
# S3 method for class 'chronicle'
as.data.frame(x, row.names = NULL, optional = FALSE, ...)
```

## Arguments

- x:

  A `chronicle` object.

- row.names:

  `NULL` or a character vector giving the row names for the data frame.

- optional:

  logical. If `TRUE`, setting row names and converting column names is
  optional.

- ...:

  Additional arguments to be passed to or from other methods.

## Value

A `data.frame` if the `value` inside the chronicle object is a
`data.frame` or can be successfully coerced into one.

## Details

The function will produce an error if the underlying `value` of the
chronicle object cannot be coerced to a data frame by the base
[`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html) method.
The error message will be specific, indicating the class of the object
that caused the failure.

## Examples

``` r
library(dplyr)
#> 
#> Attaching package: ‘dplyr’
#> The following objects are masked from ‘package:stats’:
#> 
#>     filter, lag
#> The following objects are masked from ‘package:base’:
#> 
#>     intersect, setdiff, setequal, union

# --- Successful Example ---

# Create a chronicle object whose value is a data frame
starwars_chronicle <- starwars %>%
  record(filter)(species == "Human") %>%
  bind_record(record(select), name, height, mass)

# Now, you can use as.data.frame() directly on the chronicle object
sw_df <- as.data.frame(starwars_chronicle)

class(sw_df)
#> [1] "tbl_df"     "tbl"        "data.frame"
head(sw_df)
#> # A tibble: 6 × 3
#>   name               height  mass
#>   <chr>               <int> <dbl>
#> 1 Luke Skywalker        172    77
#> 2 Darth Vader           202   136
#> 3 Leia Organa           150    49
#> 4 Owen Lars             178   120
#> 5 Beru Whitesun Lars    165    75
#> 6 Biggs Darklighter     183    84


# --- Error Example ---

# Create a chronicle object whose value is a number
numeric_chronicle <- record(sqrt)(100)

# This will fail with a specific error message because a number
# cannot be turned into a data frame.
try(as.data.frame(numeric_chronicle))
#>   value
#> 1    10
```
