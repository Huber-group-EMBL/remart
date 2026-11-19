#' Sleep until the quota resets if no requests remain
#' @noRd
.remart_rate_limit_wait <- function() {
  if (.remart_rate_limit$remaining > 0) {
    return(invisible())
  }
  wait <- as.numeric(difftime(
    .remart_rate_limit$reset,
    Sys.time(),
    units = "secs"
  ))
  if (wait > 0) {
    message(sprintf("Ensembl rate limit reached, waiting %.1f s.", wait))
    Sys.sleep(wait)
  }
  .remart_rate_limit$remaining <- .remart_rate_limit$limit
  invisible()
}

#' Record rate limit headers from a response (no-op if absent)
#' @noRd
.remart_rate_limit_update <- function(resp) {
  remaining <- httr2::resp_header(resp, "X-RateLimit-Remaining")
  reset <- httr2::resp_header(resp, "X-RateLimit-Reset")
  retry_after <- httr2::resp_header(resp, "Retry-After")
  limit <- httr2::resp_header(resp, "X-RateLimit-Limit")
  if (!is.null(limit)) {
    .remart_rate_limit$limit <- as.numeric(limit)
  }
  if (!is.null(remaining)) {
    .remart_rate_limit$remaining <- as.numeric(remaining)
  }
  if (!is.null(retry_after)) {
    # Only sent with a 429; takes precedence over `Reset`.
    reset <- retry_after
  }
  if (!is.null(reset)) {
    .remart_rate_limit$reset <- Sys.time() + as.numeric(reset)
  }
  invisible(resp)
}

#' Replacement for `httr2::req_perform()` honouring Ensembl rate limits
#' @noRd
.remart_perform <- function(req) {
  .remart_rate_limit_wait()
  # Don't error on 429 so that we can record the headers, and retry once the
  # server tells us it is safe to do so.
  req <- httr2::req_error(req, is_error = \(resp) FALSE)
  resp <- httr2::req_perform(req) |>
    .remart_rate_limit_update()
  if (httr2::resp_status(resp) == 429L) {
    .remart_rate_limit$remaining <- 0
    .remart_rate_limit_wait()
    resp <- httr2::req_perform(req) |>
      .remart_rate_limit_update()
  }
  httr2::resp_check_status(resp)
  resp
}
