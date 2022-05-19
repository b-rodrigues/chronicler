# chronicler

# chronicler 0.3.0

## New features

* Renamed `read_log()` to `read.log()` to avoid clashing with `readr::read_log()`
* Possible to log {ggplot2} functions using `ggrecord()`.
* Possible to save datasets alongside their logs to disk using `write_chronicle()`.
* New level for strict parameter in purely and record (strict = 3 now captures errors and warnings, but in case of a warning, returns the result, 4 captures errors, warnings and messages).
* filter2(), which works exactly like dplyr::filter() but raises a warning if the data frame returned is empty. 

## New vignettes

* *Saving 'chronicle' objects to disk*
* *Creating self-documenting ggplots*

# chronicler 0.2.0

## New features

* First CRAN release
