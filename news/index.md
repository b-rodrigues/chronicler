# Changelog

## chronicler 0.3.1

### Bug fixes

- Fixed scoping in
  [`record()`](https://b-rodrigues.github.io/chronicler/reference/record.md)
  and `%>=%` so decorated functions called inside another function
  (directly, via `|>`,
  [`bind_record()`](https://b-rodrigues.github.io/chronicler/reference/bind_record.md),
  or `%>=%`) resolve arguments and local variables in the caller’s
  environment without requiring explicit unquoting (`!!`).
- Fixed `%>=%` to evaluate namespaced and inline function expressions
  (e.g., `pkg::r_fun()` or `record(fun)()`).
- Fixed
  [`record_many()`](https://b-rodrigues.github.io/chronicler/reference/record_many.md)
  stripping of package namespaces (e.g., `"dplyr::select"` now generates
  `r_select` instead of `r_:select`).
- Fixed `make_log_df()` converting missing messages (`NA_character_`)
  into the literal string `"NA"`.
- Fixed
  [`record_ggplot()`](https://b-rodrigues.github.io/chronicler/reference/record_ggplot.md)
  error plots collapsing wrapped error lines with `"\n"` instead of
  overlapping multiple text layers.
- Fixed
  [`fmap_record()`](https://b-rodrigues.github.io/chronicler/reference/fmap_record.md)
  to catch errors via
  [`purely()`](https://b-rodrigues.github.io/chronicler/reference/purely.md),
  propagate `Nothing` status, and renumber `ops_number` (along with
  [`flatten_record()`](https://b-rodrigues.github.io/chronicler/reference/flatten_record.md)).
- Fixed
  [`as.data.frame.chronicle()`](https://b-rodrigues.github.io/chronicler/reference/as.data.frame.chronicle.md)
  to coerce tibbles and grouped data frames to base `data.frame` and
  honour `row.names`, `optional`, and `...`.
- Fixed
  [`write_chronicle_df()`](https://b-rodrigues.github.io/chronicler/reference/write_chronicle_df.md)
  case-insensitive extension handling, error messaging, and invisible
  `NULL` return value.

## chronicler 0.3.0

CRAN release: 2025-08-18

### New features

- [`read_log()`](https://b-rodrigues.github.io/chronicler/reference/read_log.md)
  now has “pretty”, “table”, and “errors-only” styles for viewing
  pipeline logs.
- New `write_chronicle_df` function which writes data frames to .csv or
  .xlsx formats alongside their logs.
- `as.data.frame` will coerce a `chronicle` object to data frame if its
  value can be coerced to data frame.
- New `zap_log` function that resets the log of a `chronicle` object.
- Named arguments can now be passed to functions.
- ggplots can now be recorded as well. If a plot fails, it returns “an
  error” plot: a red box with the error message shown on it. This allows
  documents that use plots that might need more tweaking to still be
  compiled.

### Chores

- General code cleanup.

## chronicler 0.2.1

CRAN release: 2023-02-03

### Maintenance release

- Compatibility with dplyr 1.1.0
- Changed link to canonical link in the Readme.md

## chronicler 0.2.0

CRAN release: 2022-05-17

### New features

- First CRAN release
