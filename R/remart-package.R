#' @keywords internal
"_PACKAGE"

## usethis namespace: start
## usethis namespace: end
NULL

# Backport from R 4.6.0
`%notin%` <- function(x, table) {
  match(x, table, nomatch = 0L) == 0
}