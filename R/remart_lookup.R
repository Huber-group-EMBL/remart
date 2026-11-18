#' Batch-fetch Ensembl feature metadata via the REST `lookup/id` or
#' `lookup/symbol` endpoint
#'
#' @param ids,symbols character vector of Ensembl stable IDs (genes, transcripts or
#'   translations are all supported by this endpoint).
#' @param expand if `TRUE`, also return the child features (e.g. transcripts
#'   and translations for a gene).
#'
#' @returns A named list of parsed JSON objects, keyed by `ids`. Missing IDs
#'   are returned as `NULL` entries.
#'
#' @noRd
.remart_lookup <- function(
  values,
  filters,
  base_url,
  species = NULL,
  expand = FALSE
) {
  switch(
    filters,
    "ensembl_gene_id" = .remart_lookup_id(
      values,
      base_url = base_url,
      expand = expand
    ),
    "ensembl_transcript_id" = .remart_lookup_id(
      values,
      base_url = base_url,
      expand = TRUE
    ),
    "external_gene_name" = .remart_lookup_symbol(
      values,
      base_url = base_url,
      species = species,
      expand = expand
    )
  )
}

.remart_lookup_id <- function(ids, base_url, expand = FALSE) {
  res <- httr2::request(base_url) |>
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

.remart_lookup_symbol <- function(
  symbols,
  base_url,
  species = NULL,
  expand = FALSE
) {
  res <- httr2::request(base_url) |>
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
