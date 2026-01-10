# Flatten nested chronicle objects

Flatten nested chronicle objects

## Usage

``` r
flatten_record(.c)
```

## Arguments

- .c:

  A nested chronicle object, where the \$value element is itself a
  chronicle object

## Value

Returns `.c` where value is the actual value, and logs are concatenated.

## Examples

``` r
r_sqrt <- record(sqrt)
r_log <- record(log)
a <- as_chronicle(r_log(10))
a
#> OK! Value computed successfully:
#> ---------------
#> Just
#> OK! Value computed successfully:
#> ---------------
#> Just
#> [1] 2.302585
#> 
#> ---------------
#> This is an object of type `chronicle`.
#> Retrieve the value of this object with unveil(.c, "value").
#> To read the log of this object, call read_log(.c).
#> 
#> 
#> ---------------
#> This is an object of type `chronicle`.
#> Retrieve the value of this object with unveil(.c, "value").
#> To read the log of this object, call read_log(.c).
#> 
flatten_record(a)
#> OK! Value computed successfully:
#> ---------------
#> Just
#> [1] 2.302585
#> 
#> ---------------
#> This is an object of type `chronicle`.
#> Retrieve the value of this object with unveil(.c, "value").
#> To read the log of this object, call read_log(.c).
#> 
```
