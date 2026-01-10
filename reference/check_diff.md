# Check the output of the diff column

Check the output of the diff column

## Usage

``` r
check_diff(.c, columns = c("ops_number", "function"))
```

## Arguments

- .c:

  A chronicle object.

- columns:

  Columns to select for the output. Defaults to c("ops_number",
  "function").

## Value

A data.frame with the selected columns and column "diff_obj".

## Details

`diff` is an option argument to the
[`record()`](https://b-rodrigues.github.io/chronicler/reference/record.md)
function. When `diff` = "full", a diff of the input and output of the
decorated function gets saved, and if `diff` = "summary" only a summary
of the diff is saved.

## Examples

``` r
r_subset <- record(subset, diff = "full")
result <- r_subset(mtcars, select = am)
check_diff(result) # <- this is the data frame listing the operations and the accompanying diffs
#>   ops_number function                                            diff_obj
#> 1          1   subset <S4 class ‘Diff’ [package “diffobj”] with 14 slots>
check_diff(result)$diff_obj # <- actually look at the diffs
#> [[1]]
#> < str(input)                             > str(output)                          
#> @@ 1,12 @@                               @@ 1,2 @@                              
#> < 'data.frame':   32 obs. of  11 variab  > 'data.frame':   32 obs. of  1 variabl
#> : les:                                   : e:                                   
#> <  $ mpg : num  21 21 22.8 21.4 18.7 18  ~                                      
#> : .1 14.3 24.4 22.8 19.2 ...             ~                                      
#> <  $ cyl : num  6 6 4 6 8 6 8 4 4 6 ...  ~                                      
#> <  $ disp: num  160 160 108 258 360 ...  ~                                      
#> <  $ hp  : num  110 110 93 110 175 105   ~                                      
#> : 245 62 95 123 ...                      ~                                      
#> <  $ drat: num  3.9 3.9 3.85 3.08 3.15   ~                                      
#> : 2.76 3.21 3.69 3.92 3.92 ...           ~                                      
#> <  $ wt  : num  2.62 2.88 2.32 3.21 3.4  ~                                      
#> : 4 ...                                  ~                                      
#> <  $ qsec: num  16.5 17 18.6 19.4 17 ..  ~                                      
#> : .                                      ~                                      
#> <  $ vs  : num  0 0 1 1 0 1 0 1 1 1 ...  ~                                      
#>    $ am  : num  1 1 1 0 0 0 0 0 0 0 ...     $ am: num  1 1 1 0 0 0 0 0 0 0 ...  
#> <  $ gear: num  4 4 4 3 3 3 3 4 4 4 ...  ~                                      
#> <  $ carb: num  4 4 1 1 2 1 4 2 2 4 ...  ~                                      
#> 
```
