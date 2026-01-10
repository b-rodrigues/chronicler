# Decorate a list of functions

Decorate a list of functions

## Usage

``` r
record_many(list_funcs, .g = (function(x) NA), strict = 2, diff = "none")
```

## Arguments

- list_funcs:

  A list of function names, as strings.

- .g:

  Optional. Defaults to a function which returns NA.

- strict:

  Controls if the decorated function should catch only errors (1),
  errors and warnings (2, the default) or errors, warnings and messages
  (3).

- diff:

  Whether to show the diff between the input and the output ("full"),
  just a summary of the diff ("summary"), or none ("none", the default)

## Value

Puts a string into the systems clipboard.

## Details

Functions must be entered as strings of the form "function" or
"package::function". The code gets generated and copied into the
clipboard. The code can then be pasted into the text editor. On
GNU/Linux systems, you might get the following error message on first
use: "Error in : Clipboard on X11 requires that the DISPLAY envvar be
configured". This is an error message from
[`clipr::write_clip()`](http://matthewlincoln.net/clipr/reference/write_clip.md),
used by `record_many()` to put the generated code into the system's
clipboard. To solve this issue, run `echo $DISPLAY` in the system's
shell. This command should return a string like ":0". Take note of this
string. In your .Rprofile, put the following command: Sys.setenv(DISPLAY
= ":0") and restart the R session. `record_many()` should now work.

## Examples

``` r
if (FALSE) { # \dontrun{
list_funcs <- list("exp", "dplyr::select", "exp")
record_many(list_funcs)
} # }
```
