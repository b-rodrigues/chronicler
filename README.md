
<!-- README.md is generated from README.Rmd. Please edit that file -->

# chronicler

<!-- badges: start -->
<!-- badges: end -->

Easily add logs to your functions.

## Installation

You can install the development version of loud from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("b-rodrigues/chronicler")
```

## Introduction

{chronicler} allows you to decorate functions make them provide enhanced
output:

``` r
library(chronicler)

r_sqrt <- record(sqrt)

a <- r_sqrt(1:5)
```

Object `a` is now an object of class `loud`. The value of the `sqrt()`
function applied to its arguments can be obtained using `pick()`:

``` r
pick(a, "value")
#> [1] 1.000000 1.414214 1.732051 2.000000 2.236068
```

A log also gets generated and can be read using `read_log()`:

``` r
read_log(a)
#> [1] "Complete log:"                                             
#> [2] "<U+2714> sqrt(1:5) ran successfully at 2022-04-01 11:14:43"
#> [3] "Total running time: 0.00099492073059082 secs"
```

This is especially useful for objects that get created using multiple
calls:

``` r
r_sqrt <- record(sqrt)
r_exp <- record(exp)
r_mean <- record(mean)

b <- 1:10 |>
  r_sqrt() |>
  bind_record(r_exp) |>
  bind_record(r_mean)
```

``` r
read_log(b)
#> [1] "Complete log:"                                                  
#> [2] "<U+2714> sqrt(1:10) ran successfully at 2022-04-01 11:14:43"    
#> [3] "<U+2714> exp(.c$value) ran successfully at 2022-04-01 11:14:43" 
#> [4] "<U+2714> mean(.c$value) ran successfully at 2022-04-01 11:14:43"
#> [5] "Total running time: 0.00805497169494629 secs"

pick(b, "value")
#> [1] 11.55345
```

## Composing decorated functions

`bind_record()` is used to pass the output from one decorated function
to the next.

`record()` works with any function:

``` r
library(dplyr)

r_group_by <- record(group_by)
r_select <- record(select)
r_summarise <- record(summarise)
r_filter <- record(filter)

output <- starwars %>%
  r_select(height, mass, species, sex) %>%
  bind_record(r_group_by, species, sex) %>%
  bind_record(r_filter, sex != "male") %>%
  bind_record(r_summarise,
              mass = mean(mass, na.rm = TRUE)
              )
```

``` r
read_log(output)
#> [1] "Complete log:"                                                                                
#> [2] "<U+2714> select(.,height,mass,species,sex) ran successfully at 2022-04-01 11:14:43"           
#> [3] "<U+2714> group_by(.c$value,species,sex) ran successfully at 2022-04-01 11:14:43"              
#> [4] "<U+2714> filter(.c$value,sex != \"male\") ran successfully at 2022-04-01 11:14:43"            
#> [5] "<U+2714> summarise(.c$value,mean(mass, na.rm = TRUE)) ran successfully at 2022-04-01 11:14:43"
#> [6] "Total running time: 0.0585381984710693 secs"
```

The value can then be accessed and worked on as usual using `pick()`:

``` r
pick(output, "value")
#> tibble [9, 3] 
#> grouped by: species [9] 
#> species chr Clawdite Droid Human Hutt Kaminoan Mirialan
#> sex     chr female none female hermaphroditic female female
#> mass    dbl 55 69.75 56.333333 1358 NaN 53.1
```

This package also ships with a dedicated pipe, `%>=%` which you can use
instead of `bind_record()`:

``` r
output_pipe <- starwars %>%
  as_chronicle() %>=%
  r_select(height, mass, species, sex) %>=%
  r_group_by(species, sex) %>=%
  r_filter(sex != "male") %>=%
  r_summarise(mass = mean(mass, na.rm = TRUE))
```

``` r
pick(output_pipe, "value")
#> tibble [9, 3] 
#> grouped by: species [9] 
#> species chr Clawdite Droid Human Hutt Kaminoan Mirialan
#> sex     chr female none female hermaphroditic female female
#> mass    dbl 55 69.75 56.333333 1358 NaN 53.1
```

Objects of class `chronicle` have their own print method:

``` r
output_pipe
#> <U+2714> Value computed successfully:
#> ---------------
#> tibble [9, 3] 
#> grouped by: species [9] 
#> species chr Clawdite Droid Human Hutt Kaminoan Mirialan
#> sex     chr female none female hermaphroditic female female
#> mass    dbl 55 69.75 56.333333 1358 NaN 53.1 
#> 
#> ---------------
#> This is an object of type `chronicle`.
#> Retrieve the value of this object with pick(.c, "value").
#> To read the log of this object, call read_log().
```

## Condition handling

By default, errors and warnings get caught and composed in the log:

``` r
errord_output <- starwars %>%
  as_chronicle() %>=%
  r_select(height, mass, species, sex) %>=% 
  r_group_by(species, sx) %>=% # typo, "sx" instead of "sex"
  r_filter(sex != "male") %>=%
  r_summarise(mass = mean(mass, na.rm = TRUE))
```

``` r
errord_output
#> <U+2716> Value computed unsuccessfully <U+2716>:
#> ---------------
#> [1] NA
#> 
#> ---------------
#> This is an object of type `chronicle`.
#> Retrieve the value of this object with pick(.c, "value").
#> To read the log of this object, call read_log().
```

Reading the log tells you which function failed, and with which error
message:

``` r
read_log(errord_output)
#> [1] "Complete log:"                                                                                                                                                                                           
#> [2] "<U+2714> as_chronicle(NA) ran successfully at 2022-04-01 11:14:43"                                                                                                                                       
#> [3] "<U+2714> select(.c$value,height,mass,species,sex) ran successfully at 2022-04-01 11:14:43"                                                                                                               
#> [4] "<U+2716> group_by(.c$value,species,sx) ran unsuccessfully with following exception: Must group by variables found in `.data`.\nx Column `sx` is not found. at 2022-04-01 11:14:43"                       
#> [5] "<U+2716> filter(.c$value,sex != \"male\") ran unsuccessfully with following exception: no applicable method for 'filter' applied to an object of class \"logical\" at 2022-04-01 11:14:43"               
#> [6] "<U+2716> summarise(.c$value,mean(mass, na.rm = TRUE)) ran unsuccessfully with following exception: no applicable method for 'summarise' applied to an object of class \"logical\" at 2022-04-01 11:14:43"
#> [7] "Total running time: 0.109799146652222 secs"
```

It is also possible to only capture errors, or catpure errors, warnings
and messages using the `strict` parameter of `loud()`

``` r
# Only errors:

r_sqrt <- record(sqrt, strict = 1)

r_sqrt(-10) |>
  read_log()
#> Warning in .f(...): NaNs produced
#> [1] "Complete log:"                                                                            
#> [2] "<U+2716> sqrt(-10) ran unsuccessfully with following exception: NA at 2022-04-01 11:14:44"
#> [3] "Total running time: 0 secs"

# Errors and warnings:

r_sqrt <- record(sqrt, strict = 2)

r_sqrt(-10) |>
  read_log()
#> [1] "Complete log:"                                                                                       
#> [2] "<U+2716> sqrt(-10) ran unsuccessfully with following exception: NaNs produced at 2022-04-01 11:14:44"
#> [3] "Total running time: 0 secs"

# Errors, warnings and messages

my_f <- function(x){
  message("this is a message")
  10
}

record(my_f, strict = 3)(10) |>
                         read_log()
#> [1] "Complete log:"                                                                                            
#> [2] "<U+2716> my_f(10) ran unsuccessfully with following exception: this is a message\n at 2022-04-01 11:14:44"
#> [3] "Total running time: 0.00099492073059082 secs"
```

## Thanks

I’d like to thank [armcn](https://github.com/armcn),
[Kupac](https://github.com/Kupac) for their blog posts
([here](https://kupac.gitlab.io/biofunctor/2019/05/25/maybe-monad-in-r/))
and packages ([maybe](https://armcn.github.io/maybe/)) which inspired me
to build this package.
