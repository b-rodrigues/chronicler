# Decorates a function to output objects of type `chronicle`.

Decorates a function to output objects of type `chronicle`.

## Usage

``` r
record(.f, .g = (function(x) NA), strict = 2, diff = "none")
```

## Arguments

- .f:

  A function to decorate.

- .g:

  Optional. A function to apply to the intermediary results for
  monitoring purposes. Defaults to returning NA.

- strict:

  Controls if the decorated function should catch only errors (1),
  errors and warnings (2, the default) or errors, warnings and messages
  (3).

- diff:

  Whether to show the diff between the input and the output ("full"),
  just a summary of the diff ("summary"), or none ("none", the default)

## Value

A function which returns objects of type `chronicle`. `chronicle`
objects carry several elements: a `value` which is the result of the
function evaluated on its inputs and a second object called `log_df`.
`log_df` contains logging information, which can be read using
[`read_log()`](https://b-rodrigues.github.io/chronicler/reference/read_log.md).
`log_df` is a data frame with columns: outcome, function, arguments,
message, start_time, end_time, run_time, g and diff_obj.

## Details

To chain multiple decorated function, use
[`bind_record()`](https://b-rodrigues.github.io/chronicler/reference/bind_record.md)
or `%>=%`. If the `diff` parameter is set to "full",
[`diffobj::diffObj()`](https://rdrr.io/pkg/diffobj/man/diffObj.html) (or
`diffobj::summary(diffobj::diffObj()`, if diff is set to "summary") gets
used to provide the diff between the input and the output. This diff can
be found in the `log_df` element of the result, and can be viewed using
[`check_diff()`](https://b-rodrigues.github.io/chronicler/reference/check_diff.md).

## Examples

``` r
record(sqrt)(10)
#> OK! Value computed successfully:
#> ---------------
#> Just
#> [1] 3.162278
#> 
#> ---------------
#> This is an object of type `chronicle`.
#> Retrieve the value of this object with unveil(.c, "value").
#> To read the log of this object, call read_log(.c).
#> 
record(sqrt)(x = 10)
#> OK! Value computed successfully:
#> ---------------
#> Just
#> [1] 3.162278
#> 
#> ---------------
#> This is an object of type `chronicle`.
#> Retrieve the value of this object with unveil(.c, "value").
#> To read the log of this object, call read_log(.c).
#> 
```
