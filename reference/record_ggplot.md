# Record a ggplot expression

`record_ggplot` captures a complete `{ggplot2}` expression, evaluates
it, and creates a `chronicle` object. It uses a robust `tryCatch` and
`withCallingHandlers` pattern to reliably capture errors, warnings, and
messages.

To trigger all conditions, including rendering-time warnings and
messages, it forces a full render of the plot. This is achieved safely
by opening a null graphics device (`pdf(NULL)`), scheduling its closure
with `on.exit(dev.off())`, and then printing the plot. This guarantees
that the temporary device is always closed, even if an error occurs,
preventing any side effects on the user's active graphics session.

## Usage

``` r
record_ggplot(ggplot_expression, strict = 2)
```

## Arguments

- ggplot_expression:

  The entire `{ggplot2}` expression to be recorded.

- strict:

  An optional integer argument controlling what is treated as a failure:

  - `1`: Catches only errors.

  - `2`: Catches errors and warnings (the default).

  - `3`: Catches errors, warnings, and messages.

## Value

A `chronicle` object. When printed, it will display the plot if
successful or an error plot if it failed.
