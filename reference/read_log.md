# Read and display the log of a chronicle

`read_log()` provides different human-readable views of the log
information stored in a `chronicle` object. It can show a pretty,
narrative-style summary, a tabular summary suitable for inspection or
debugging, or a compact error-focused report.

## Usage

``` r
read_log(.c, style = c("pretty", "table", "errors-only"))
```

## Arguments

- .c:

  A chronicle object.

- style:

  A string indicating the display style. One of:

  - `"pretty"`: a short, human-friendly log with OK/NOK status, function
    names, timestamps, and runtimes.

  - `"table"`: a tabular summary of the log as a data frame, including
    function names, status, runtime, and messages.

  - `"errors-only"`: a minimal report. If all steps succeed, only a
    single success message is shown. If any step fails, only the
    failures are listed.

## Value

- If `style = "pretty"`: a character vector of sentences.

- If `style = "table"`: a data frame summarising the log (with an
  attribute `"total_runtime_secs"` storing the total runtime in
  seconds).

- If `style = "errors-only"`: a character string if all succeeded, or a
  character vector listing only the failed steps.

## Examples

``` r
r_select <- record(dplyr::select)
r_group_by <- record(dplyr::group_by)
r_summarise <- record(dplyr::summarise)

output <- dplyr::starwars |>
  r_select(height, mass, species, sex) |>
  bind_record(r_group_by, species, sex) |>
  bind_record(r_summarise, mass = mean(mass, na.rm = TRUE))

read_log(output, style = "pretty")
#> [1] "OK `dplyr::select` at 12:42:06 (0.002s)"   
#> [2] "OK `dplyr::group_by` at 12:42:06 (0.003s)" 
#> [3] "OK `dplyr::summarise` at 12:42:06 (0.004s)"
#> [4] "Total: 0.008 secs"                         
read_log(output, style = "table")
#>   step             func status runtime message
#> 1    1    dplyr::select     OK   0.002      NA
#> 2    2  dplyr::group_by     OK   0.003      NA
#> 3    3 dplyr::summarise     OK   0.004      NA
read_log(output, style = "errors-only")
#> [1] "Pipeline ran 3 steps successfully in 0.008 secs"
```
