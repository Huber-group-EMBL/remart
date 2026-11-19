.remart_rate_limit <- new.env(parent = emptyenv())

.onLoad <- function(libname, pkgname) {
  # Ensembl REST rate limit state, see
  # https://github.com/Ensembl/ensembl-rest/wiki/Rate-Limits
  # - `remaining`: last seen `X-RateLimit-Remaining` (requests left in period)
  # - `reset`: time at which the quota resets, computed from the last seen
  #   `X-RateLimit-Reset` (seconds until reset) as a POSIXct.
  # - `limit` is the last seen `X-RateLimit-Limit`; quota restored after a wait
  # (Ensembl default).
  .remart_rate_limit$remaining <- Inf
  .remart_rate_limit$reset <- Sys.time()
  .remart_rate_limit$limit <- 55000
}
