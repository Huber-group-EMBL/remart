.remart_xrefs <- function(
  values,
  filters,
  species = NULL,
  db
) {
  lapply(values, function(val) {
    switch(
      filters,
      "ensembl_gene_id" = .remart_xrefs_id(
        val,
        db = db
      ),
      "ensembl_transcript_id" = .remart_xrefs_id(val, db = db),
      "external_gene_name" = .remart_xrefs_symbol(
        val,
        species = species,
        db = db
      )
    )
  })
}

.remart_xrefs_id <- function(id, db) {
  res <- httr2::request("https://rest.ensembl.org") |>
    httr2::req_url_path("/xrefs/id") |>
    httr2::req_url_path_append(id) |>
    httr2::req_method("GET") |>
    httr2::req_user_agent(REMART_USER_AGENT) |>
    httr2::req_body_json(
      db = db
    ) |>
    httr2::req_perform() |>
    httr2::resp_body_json(simplifyVector = FALSE)

  res %||% NA_character_
}

.remart_xrefs_symbol <- function(symbol, species, db) {
  res <- httr2::request("https://rest.ensembl.org") |>
    httr2::req_url_path("/xrefs/symbol") |>
    httr2::req_url_path_append(species) |>
    httr2::req_url_path_append(symbol) |>
    httr2::req_method("GET") |>
    httr2::req_user_agent(REMART_USER_AGENT) |>
    httr2::req_body_json(
      db = db
    ) |>
    httr2::req_perform() |>
    httr2::resp_body_json(simplifyVector = FALSE)

  res %||% NA_character_
}
