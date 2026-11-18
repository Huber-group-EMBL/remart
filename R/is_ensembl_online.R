#' Check if a specific Ensembl version is online
#'
#' @param version The Ensembl version to check. If `NULL` (the default),
#' checks the current version.
#'
#' @returns `TRUE` if the specified Ensembl version is online, `FALSE` otherwise.
#'
#' @export
#'
#' @examples
#' is_ensembl_online(version = "may2024")
#'
is_ensembl_online <- function(version = NULL) {
  url <- .construct_versioned_url(version)
  tryCatch(
    {
      httr2::request(url) |>
        httr2::req_url_path("/info/ping") |>
        httr2::req_headers(
          `content-type` = "application/json"
        ) |>
        httr2::req_user_agent(REMART_USER_AGENT) |>
        httr2::req_perform() |>
        httr2::resp_body_json() |>
        unname() |>
        as.logical()
    },
    error = function(e) {
      FALSE
    }
  )
}
