# Retrieve an element from a chronicle object.

Retrieve an element from a chronicle object.

## Usage

``` r
unveil(.c, .e = "value")
```

## Arguments

- .c:

  A chronicle object.

- .e:

  Element of interest to retrieve, one of "value" (default) or "log_df".

## Value

The `value` or `log_df` element of the chronicle object .c.

## Examples

``` r
r_sqrt <- record(sqrt)
r_exp <- record(exp)
3 |> r_sqrt() %>=% r_exp() |> unveil("value")
#> [1] 5.652234
```
