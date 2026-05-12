%dw 2.0
import isBlank, upper from dw::core::Strings

/**
 * Batch field values: uppercase, drop blanks, distinct after normalization.
 */
fun uniqueUpper(values) =
  (values default [])
    map ((v) -> upper(v as String default ""))
    filter ((v) -> !isBlank(v))
    distinctBy ((v) -> v)

/**
 * Comma-separated query value (e.g. REST Countries `codes`, Frankfurter `quotes`).
 * Pass `exclude: []` when nothing should be filtered out.
 */
fun commaParam(values, exclude) =
  uniqueUpper(values) filter ((v) -> !(exclude contains v)) joinBy ","
