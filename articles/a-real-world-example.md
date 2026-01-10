# A real world example

This is practically the same code you can find on this blog post of
mine: <https://brodrigues.co/posts/2018-11-14-luxairport.html> with some
minor updates to reflect the current state of the
[tidyverse](https://tidyverse.tidyverse.org) packages as well as logging
using `{chronicler}`.

Let’s first load the required packages, and the `avia` dataset included
in the `{chronicler}` package:

``` r
library(chronicler)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
library(tidyr)
library(lubridate)
#> 
#> Attaching package: 'lubridate'
#> The following objects are masked from 'package:base':
#> 
#>     date, intersect, setdiff, union

data("avia")
```

Now I need to define the needed functions for the analysis. To improve
logging, I add the [`dim()`](https://rdrr.io/r/base/dim.html) function
as the `.g` argument of each function below. This will make it possible
to see how the dimensions of the data change inside the pipeline:

``` r
# Define required functions
# You can use `record_many()` to avoid having to write everything

r_select <- record(select, .g = dim)
r_pivot_longer <- record(pivot_longer, .g = dim)
r_filter <- record(filter, .g = dim)
r_separate <- record(separate, .g = dim)
r_group_by <- record(group_by, .g = dim)
r_summarise <- record(summarise, .g = dim)
```

We can now start by preparing the data:

``` r
avia_clean <- avia %>%
  r_select(1, contains("20")) %>% # select the first column and every column starting with 20
  bind_record(r_pivot_longer,
              -starts_with("freq"),
              names_to = "date",
              values_to = "passengers") %>%
  bind_record(r_separate,
              col = 1,
              into = c("freq", "unit", "tra_meas", "air_pr\\time"),
              sep = ",")
```

Let’s take a look at the data:

``` r
avia_clean
#> OK! Value computed successfully:
#> ---------------
#> Just
#> # A tibble: 464,616 × 6
#>    freq  unit   tra_meas `air_pr\\time`  date    passengers
#>    <chr> <chr>  <chr>    <chr>           <chr>   <chr>     
#>  1 M     FLIGHT CAF_PAS  LU_ELLX_AT_LOWW 2000    :         
#>  2 M     FLIGHT CAF_PAS  LU_ELLX_AT_LOWW 2001    :         
#>  3 M     FLIGHT CAF_PAS  LU_ELLX_AT_LOWW 2002    :         
#>  4 M     FLIGHT CAF_PAS  LU_ELLX_AT_LOWW 2003    :         
#>  5 M     FLIGHT CAF_PAS  LU_ELLX_AT_LOWW 2004    :         
#>  6 M     FLIGHT CAF_PAS  LU_ELLX_AT_LOWW 2005    :         
#>  7 M     FLIGHT CAF_PAS  LU_ELLX_AT_LOWW 2005-01 143       
#>  8 M     FLIGHT CAF_PAS  LU_ELLX_AT_LOWW 2005-02 134       
#>  9 M     FLIGHT CAF_PAS  LU_ELLX_AT_LOWW 2005-03 154       
#> 10 M     FLIGHT CAF_PAS  LU_ELLX_AT_LOWW 2005-04 142       
#> # ℹ 464,606 more rows
#> 
#> ---------------
#> This is an object of type `chronicle`.
#> Retrieve the value of this object with unveil(.c, "value").
#> To read the log of this object, call read_log(.c).
```

The passengers column contains `":"` characters instead of `NA`s, and
it’s a character column. Let’s convert this column to numbers:

``` r
r_mutate <- record(mutate, .g = dim)

avia_clean2 <- avia_clean %>%
  bind_record(r_mutate,
              passengers = as.numeric(passengers))
```

Let’s look at the data:

``` r
avia_clean2
#> NOK! Value computed unsuccessfully:
#> ---------------
#> Nothing
#> 
#> ---------------
#> This is an object of type `chronicle`.
#> Retrieve the value of this object with unveil(.c, "value").
#> To read the log of this object, call read_log(.c).
```

What happened? Let’s read the log to find out!

``` r
read_log(avia_clean2)
#> [1] "OK `select` at 12:40:03 (0.008s)"      
#> [2] "OK `pivot_longer` at 12:40:03 (0.021s)"
#> [3] "OK `separate` at 12:40:03 (4.876s)"    
#> [4] "NOK `mutate` at 12:40:08 (0.324s)"     
#> [5] "Total: 5.229 secs"
```

So what happened is that
[`as.numeric()`](https://rdrr.io/r/base/numeric.html) introduced `NA`s
by coercion. This is what happens when trying to convert a character to
a number, for example `as.numeric(":")` will result in an `NA`. Because
[`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html) was
recorded with the default value for its `strict` argument (which is
`2`), warnings get promoted to errors. This can be quite useful to avoid
problems with silent conversions. But in this case, we want to ignore
the warning: let’s record
[`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html) with
`strict = 1`, so that only errors can stop the pipeline:

``` r
r_mutate_lenient <- record(mutate, .g = dim, strict = 1)

avia_clean2 <- avia_clean %>%
  bind_record(r_mutate_lenient,
              passengers = as.numeric(passengers)
              )
#> Warning: There was 1 warning in `.f()`.
#> ℹ In argument: `passengers = as.numeric(passengers)`.
#> Caused by warning:
#> ! NAs introduced by coercion
```

As you can see, the warnings get printed, they’re not captured. We can
now take a look at the data and see that `":"` characters where
successfully replaced by `NA`s:

``` r
avia_clean2
#> OK! Value computed successfully:
#> ---------------
#> Just
#> # A tibble: 464,616 × 6
#>    freq  unit   tra_meas `air_pr\\time`  date    passengers
#>    <chr> <chr>  <chr>    <chr>           <chr>        <dbl>
#>  1 M     FLIGHT CAF_PAS  LU_ELLX_AT_LOWW 2000            NA
#>  2 M     FLIGHT CAF_PAS  LU_ELLX_AT_LOWW 2001            NA
#>  3 M     FLIGHT CAF_PAS  LU_ELLX_AT_LOWW 2002            NA
#>  4 M     FLIGHT CAF_PAS  LU_ELLX_AT_LOWW 2003            NA
#>  5 M     FLIGHT CAF_PAS  LU_ELLX_AT_LOWW 2004            NA
#>  6 M     FLIGHT CAF_PAS  LU_ELLX_AT_LOWW 2005            NA
#>  7 M     FLIGHT CAF_PAS  LU_ELLX_AT_LOWW 2005-01        143
#>  8 M     FLIGHT CAF_PAS  LU_ELLX_AT_LOWW 2005-02        134
#>  9 M     FLIGHT CAF_PAS  LU_ELLX_AT_LOWW 2005-03        154
#> 10 M     FLIGHT CAF_PAS  LU_ELLX_AT_LOWW 2005-04        142
#> # ℹ 464,606 more rows
#> 
#> ---------------
#> This is an object of type `chronicle`.
#> Retrieve the value of this object with unveil(.c, "value").
#> To read the log of this object, call read_log(.c).
```

Let’s continue and focus on monthly data:

``` r
avia_monthly <- avia_clean2 %>%
  bind_record(r_filter,
              freq == "M",
              tra_meas == "PAS_BRD_ARR",
              !is.na(passengers)) %>%
  bind_record(r_mutate,
              date = paste0(date, "01"),
              date = ymd(date)) %>%
  bind_record(r_select,
              destination = "air_pr\\time", date, passengers)
```

To make sure I only have monthly data, I can count the values of the
`date` column using
[`dplyr::count()`](https://dplyr.tidyverse.org/reference/count.html).
But because `avia_monthly` is not a data frame, but a `chronicle` I need
to
[`record()`](https://b-rodrigues.github.io/chronicler/reference/record.md)
the [`dplyr::count()`](https://dplyr.tidyverse.org/reference/count.html)
function. But because I only need it this once, I could instead use
[`fmap_record()`](https://b-rodrigues.github.io/chronicler/reference/fmap_record.md),
which makes it possible to apply an undecorated function to a
`chronicle` object:

``` r
fmap_record(avia_monthly, count, date)
#> OK! Value computed successfully:
#> ---------------
#> Just
#> # A tibble: 226 × 2
#>    date           n
#>    <date>     <int>
#>  1 2005-01-01    23
#>  2 2005-02-01    23
#>  3 2005-03-01    23
#>  4 2005-04-01    24
#>  5 2005-05-01    24
#>  6 2005-06-01    24
#>  7 2005-07-01    24
#>  8 2005-08-01    24
#>  9 2005-09-01    24
#> 10 2005-10-01    24
#> # ℹ 216 more rows
#> 
#> ---------------
#> This is an object of type `chronicle`.
#> Retrieve the value of this object with unveil(.c, "value").
#> To read the log of this object, call read_log(.c).
```

`avia_monthly` is an object of class `chronicle`, but in essence, it is
just a list, with its own print method:

``` r
avia_monthly
#> OK! Value computed successfully:
#> ---------------
#> Just
#> # A tibble: 6,643 × 3
#>    destination     date       passengers
#>    <chr>           <date>          <dbl>
#>  1 LU_ELLX_AT_LOWW 2005-01-01       1758
#>  2 LU_ELLX_AT_LOWW 2005-02-01       1843
#>  3 LU_ELLX_AT_LOWW 2005-03-01       2129
#>  4 LU_ELLX_AT_LOWW 2005-04-01       2332
#>  5 LU_ELLX_AT_LOWW 2005-05-01       2402
#>  6 LU_ELLX_AT_LOWW 2005-06-01       2475
#>  7 LU_ELLX_AT_LOWW 2005-07-01       2082
#>  8 LU_ELLX_AT_LOWW 2005-08-01       2175
#>  9 LU_ELLX_AT_LOWW 2005-09-01       2288
#> 10 LU_ELLX_AT_LOWW 2005-10-01       2296
#> # ℹ 6,633 more rows
#> 
#> ---------------
#> This is an object of type `chronicle`.
#> Retrieve the value of this object with unveil(.c, "value").
#> To read the log of this object, call read_log(.c).
```

Now that the data is clean, we can read the log:

``` r
read_log(avia_monthly)
#> [1] "OK `select` at 12:40:03 (0.008s)"      
#> [2] "OK `pivot_longer` at 12:40:03 (0.021s)"
#> [3] "OK `separate` at 12:40:03 (4.876s)"    
#> [4] "OK `mutate` at 12:40:09 (0.074s)"      
#> [5] "OK `filter` at 12:40:09 (0.011s)"      
#> [6] "OK `mutate` at 12:40:09 (0.010s)"      
#> [7] "OK `select` at 12:40:09 (0.002s)"      
#> [8] "Total: 5.002 secs"
```

This is especially useful if the object `avia_monthly` gets saved using
[`saveRDS()`](https://rdrr.io/r/base/readRDS.html). People can then read
this object, can read the log to know what happened and reproduce the
steps if necessary.

Let’s take a look at the final data set:

``` r
avia_monthly %>%
  unveil("value")
#> # A tibble: 6,643 × 3
#>    destination     date       passengers
#>    <chr>           <date>          <dbl>
#>  1 LU_ELLX_AT_LOWW 2005-01-01       1758
#>  2 LU_ELLX_AT_LOWW 2005-02-01       1843
#>  3 LU_ELLX_AT_LOWW 2005-03-01       2129
#>  4 LU_ELLX_AT_LOWW 2005-04-01       2332
#>  5 LU_ELLX_AT_LOWW 2005-05-01       2402
#>  6 LU_ELLX_AT_LOWW 2005-06-01       2475
#>  7 LU_ELLX_AT_LOWW 2005-07-01       2082
#>  8 LU_ELLX_AT_LOWW 2005-08-01       2175
#>  9 LU_ELLX_AT_LOWW 2005-09-01       2288
#> 10 LU_ELLX_AT_LOWW 2005-10-01       2296
#> # ℹ 6,633 more rows
```

It is also possible to take a look at the underlying `.log_df` object
that contains more details, and see the output of the `.g` argument
(which was defined in the beginning as the
[`dim()`](https://rdrr.io/r/base/dim.html) function):

``` r
check_g(avia_monthly)
#>   ops_number     function         g
#> 1          1       select 1434, 325
#> 2          2 pivot_longer 464616, 3
#> 3          3     separate 464616, 6
#> 4          4       mutate 464616, 6
#> 5          5       filter   6643, 6
#> 6          6       mutate   6643, 6
#> 7          7       select   6643, 3
```

After [`select()`](https://dplyr.tidyverse.org/reference/select.html)
the data has `hu[[1]][1]` rows and `hu[[1]][2]` columns, after the call
to
[`pivot_longer()`](https://tidyr.tidyverse.org/reference/pivot_longer.html),
`hu[[2]][1]` rows and `hu[[2]][2]` columns,
[`separate()`](https://tidyr.tidyverse.org/reference/separate.html) adds
three columns, after
[`filter()`](https://dplyr.tidyverse.org/reference/filter.html) only
`hu[[5]][1]` rows remain
([`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html) does
not change the dimensions) and then
[`select()`](https://dplyr.tidyverse.org/reference/select.html) is used
to remove three columns.
