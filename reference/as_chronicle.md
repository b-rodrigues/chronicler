# Coerce an object to a chronicle object.

Coerce an object to a chronicle object.

## Usage

``` r
as_chronicle(.x, .log_df = data.frame())
```

## Arguments

- .x:

  Any object.

- .log_df:

  Used internally, the user does need to interact with it. Defaults to
  an empty data frame.

## Value

Returns a chronicle object with the object as the \$value.

## Examples

``` r
as_chronicle(3)
#> OK! Value computed successfully:
#> ---------------
#> Just
#> [1] 3
#> 
#> ---------------
#> This is an object of type `chronicle`.
#> Retrieve the value of this object with unveil(.c, "value").
#> To read the log of this object, call read_log(.c).
#> 
```
