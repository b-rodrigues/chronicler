# Evaluate a non-chronicle function on a chronicle object.

Evaluate a non-chronicle function on a chronicle object.

## Usage

``` r
fmap_record(.c, .f, ...)
```

## Arguments

- .c:

  A chronicle object.

- .f:

  A non-chronicle function.

- ...:

  Further parameters to pass to `.f`.

## Value

Returns the result of `.f(.c$value)` as a new chronicle object.

## Examples

``` r
as_chronicle(3) |> fmap_record(sqrt)
#> OK! Value computed successfully:
#> ---------------
#> Just
#> [1] 1.732051
#> 
#> ---------------
#> This is an object of type `chronicle`.
#> Retrieve the value of this object with unveil(.c, "value").
#> To read the log of this object, call read_log(.c).
#> 
```
