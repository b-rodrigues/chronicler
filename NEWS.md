# chonicler 0.3.0

## New features

- `read_log()` now has "pretty", "table", and "errors-only" styles for viewing pipeline logs.
- New `write_chronicle_df` function which writes data frames to .csv or .xlsx formats alongside their logs.
- `as.data.frame` will coerce a `chronicle` object to data frame if its value can be coerced to data frame.
- New `zap_log` function that resets the log of a `chronicle` object.
- Named arguments can now be passed to functions.
- ggplots can now be recorded as well. If a plot fails, it returns "an error" plot: a red box with the error message shown on it.
  This allows documents that use plots that might need more tweaking to still be compiled.

## Chores

- General code cleanup.

# chronicler 0.2.1

## Maintenance release

* Compatibility with dplyr 1.1.0
* Changed link to canonical link in the Readme.md

# chronicler 0.2.0

## New features

* First CRAN release
