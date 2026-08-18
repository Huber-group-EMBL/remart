#' Batch-fetch Ensembl feature metadata via the REST `lookup/id` endpoint
#'
#' @param ids character vector of Ensembl stable IDs (genes, transcripts or
#'   translations are all supported by this endpoint).
#' @param expand if `TRUE`, also return the child features (e.g. transcripts
#'   and translations for a gene).
#'
#' @returns A named list of parsed JSON objects, keyed by `ids`. Missing IDs
#'   are returned as `NULL` entries.
#'
#' @noRd
.remart_lookup_id <- function(ids, expand = FALSE) {
  ids <- unique(as.character(ids))

  res <- httr2::request("https://rest.ensembl.org") |>
    httr2::req_url_path("/lookup/id") |>
    httr2::req_method("POST") |>
    httr2::req_user_agent(REMART_USER_AGENT) |>
    httr2::req_body_json(list(
      ids = as.list(ids),
      expand = as.integer(expand)
    )) |>
    httr2::req_perform() |>
    httr2::resp_body_json(simplifyVector = FALSE)

  # Ensure every requested id has an (possibly NULL) entry, and that the
  # result is returned in the same order as `ids`.
  res[ids]
}

.remart_lookup_symbol <- function(symbols, species = NULL, expand = FALSE) {
  res <- httr2::request("https://rest.ensembl.org") |>
    httr2::req_url_path("/lookup/symbol") |>
    httr2::req_url_path_append(species) |>
    httr2::req_method("POST") |>
    httr2::req_user_agent(REMART_USER_AGENT) |>
    httr2::req_body_json(list(
      symbols = as.list(symbols),
      expand = as.integer(expand)
    )) |>
    httr2::req_perform() |>
    httr2::resp_body_json(simplifyVector = FALSE)

  res[symbols]
}
