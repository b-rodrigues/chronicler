# Capture all errors, warnings and messages.

Capture all errors, warnings and messages.

## Usage

``` r
purely(.f, strict = 2)
```

## Arguments

- .f:

  A function to decorate.

- strict:

  Controls if the decorated function should catch only errors (1),
  errors and warnings (2, the default) or errors, warnings and messages
  (3).

## Value

A function which returns a list. The first element of the list,
`$value`, is the result of the original function `.f` applied to its
inputs. The second element, `$log` is `NULL` in case everything goes
well. In case of error/warning/message, `$value` is NA and `$log` holds
the message. `purely()` is used by
[`record()`](https://b-rodrigues.github.io/chronicler/reference/record.md)
to allow the latter to handle errors.

## Examples

``` r
purely(log)(10)
#> $value
#> Just
#> [1] 2.302585
#> 
#> $log_df
#> [1] NA
#> 
purely(log)(-10)
#> $value
#> Nothing
#> 
#> $log_df
#> [1] "NaNs produced"
#> 
purely(log, strict = 1)(-10) # This produces a warning, so with strict = 1 nothing gets captured.
#> Warning: NaNs produced
#> $value
#> Just
#> [1] NaN
#> 
#> $log_df
#> [1] NA
#> 
```
