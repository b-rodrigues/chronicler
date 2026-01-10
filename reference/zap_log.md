# Zap the log of a chronicle object

This function replaces the entire existing log of a `chronicle` object
with a single, new entry. This new entry simply records that the log was
"zapped" and the time at which it occurred.

This is useful for simplifying a `chronicle` object before saving or
sharing, or to mark a definitive checkpoint in a workflow, effectively
discarding the previous history. The underlying `value` of the object
remains completely unchanged.

## Usage

``` r
zap_log(.c)
```

## Arguments

- .c:

  A `chronicle` object.

## Value

A new `chronicle` object with the same `value` as the input, but with
its `log_df` replaced by a single entry.

## Examples

``` r
library(dplyr)

# 1. Create a chronicle object with a multi-step log
r_select <- record(select)
r_filter <- record(filter)

original_chronicle <- starwars %>%
  r_select(name, height, mass, species) %>%
  bind_record(r_filter, species == "Human")

# 2. View the original, detailed log
cat("--- Original Log ---\n")
#> --- Original Log ---
read_log(original_chronicle)
#> [1] "OK `select` at 12:42:08 (0.002s)" "OK `filter` at 12:42:08 (0.001s)"
#> [3] "Total: 0.002 secs"               

# 3. Zap the log
zapped_chronicle <- zap_log(original_chronicle)

# 4. View the new, simplified log
cat("\n--- Zapped Log ---\n")
#> 
#> --- Zapped Log ---
read_log(zapped_chronicle)
#> [1] "OK `zap_log` at 12:42:08 (0.000s)" "Total: 0.000 secs"                

# 5. The underlying data value is unaffected
identical(
  unveil(original_chronicle, "value"),
  unveil(zapped_chronicle, "value")
)
#> [1] TRUE
```
