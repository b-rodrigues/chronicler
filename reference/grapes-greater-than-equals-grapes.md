# Pipe a chronicle object to a decorated function.

Pipe a chronicle object to a decorated function.

## Usage

``` r
.c %>=% .f
```

## Arguments

- .c:

  A value returned by record.

- .f:

  A chronicle function to apply to the returning value of .c.

## Value

A chronicle object.

## Examples

``` r
r_sqrt <- record(sqrt)
r_exp <- record(exp)
3 |> r_sqrt() %>=% r_exp()
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
