# Evaluate a decorated function; used to chain multiple decorated functions.

Evaluate a decorated function; used to chain multiple decorated
functions.

## Usage

``` r
bind_record(.c, .f, ...)
```

## Arguments

- .c:

  A chronicle object.

- .f:

  A chronicle function to apply to the returning value of .c.

- ...:

  Further parameters to pass to .f.

## Value

A chronicle object.

## Examples

``` r
r_sqrt <- record(sqrt)
r_exp <- record(exp)
3 |> r_sqrt() |> bind_record(r_exp)
#> OK! Value computed successfully:
#> ---------------
#> Just
#> [1] 5.652234
#> 
#> ---------------
#> This is an object of type `chronicle`.
#> Retrieve the value of this object with unveil(.c, "value").
#> To read the log of this object, call read_log(.c).
#> 
```
