as_chronicle <- function(a) {
  structure(a, class = "chronicle2")
}

is_chronicle <- function(a) {
  identical(class(a), "chronicle2")
}

time_function <- function(.f) {
  function(...) {
    elapsed <- system.time({
      value <- .f(...)
    })[3L]

    as_chronicle(
      list(
        value = value,
        log = paste0(
          "Function took ",
          unname(elapsed),
          " seconds"
        )
      )
    )
  }
}

record <- function(.f) {
  time_function(maybe::maybe(.f))
}

fmap <- function(.c, .f, ...) {
  as_chronicle(
    list(
      value = maybe::fmap(.c$value, .f, ...),
      log = .c$log
    )
  )
}

bind <- function(.c, .f, ...) {
  if (maybe::is_just(.c$value)) {
    new_chronicle <-
      .f(maybe::from_just(.c$value), ...)

    new_log <-
      if (maybe::is_just(new_chronicle$value))
        c(.c$log, new_chronicle$log)

      else
        c(.c$log, "Function call failed")

    list(
      value = new_chronicle$value,
      log = new_log
    )
  } else {
    list(
      value = maybe::nothing(),
      log = c(.c$log, "Pipeline failed upstream")
    )
  } |>
    as_chronicle()
}

join <- function(.c) {
  if (is_chronicle(.c) && is_chronicle(.c$value))
    as_chronicle(
      list(
        value = .c$value$value,
        log = c(.c$value$log, .c$log)
      )
    )

  else
    .c
}

pick_log <- function(.c) {
  .c$log
}

pick_maybe <- function(.c) {
  .c$value
}

pick_value <- function(.c, default) {
  if (maybe::is_just(.c$value))
    .c$value

  else
    default
}

1:10 |>
  record(mean)() |>
  bind(record(sqrt)) |>
  bind(record(exp))

1:10 |>
  record(mean)() |>
  bind(record(sqrt)) |>
  bind(record(exp)) |>
  pick_log()

-1 |>
  record(mean)() |>
  bind(record(sqrt)) |>
  bind(record(exp))

-1 |>
  record(mean)() |>
  bind(record(sqrt)) |>
  bind(record(exp)) |>
  pick_value(default = 0)
