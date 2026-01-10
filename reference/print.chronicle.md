# Print method for chronicle objects.

Print method for chronicle objects.

## Usage

``` r
# S3 method for class 'chronicle'
print(x, ...)
```

## Arguments

- x:

  A chronicle object.

- ...:

  Unused.

## Value

No return value, called for side effects (printing the object on
screen).

## Details

`chronicle` object are, at their core, lists with the following
elements:

- "\$value": a an object of type `maybe` containing the result of the
  computation (see the "Maybe monad" vignette for more details on
  `maybe`s).

- "\$log_df": a `data.frame` object containing the printed object’s log
  information.

`print.chronicle()` prints the object on screen and shows:

- the value using its [`print()`](https://rdrr.io/r/base/print.html)
  method (for example, if the value is a data.frame,
  [`print.data.frame()`](https://rdrr.io/r/base/print.dataframe.html)
  will be used)

- a message indicating to the user how to recuperate the value inside
  the `chronicle` object and how to read the object’s log
