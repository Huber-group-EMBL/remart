#' Fetch orthologues of `id` in `target_species` from the REST `homology/id`
#' endpoint
#' @noRd
.remart_homologies_id <- function(id, version = NULL, species, target_species) {
  resp <- httr2::request(.construct_versioned_url(version)) |>
    httr2::req_url_path(sprintf("/homology/id/%s/%s", species, id)) |>
    httr2::req_url_query(
      type = "orthologues",
      sequence = "none",
      target_species = target_species,
      `content-type` = "application/json"
    ) |>
    httr2::req_user_agent(REMART_USER_AGENT) |>
    httr2::req_perform() |>
    httr2::resp_body_json(simplifyVector = FALSE)

  resp$data[[1]]$homologies
}

.remart_homologies_symbol <- function(
  symbol,
  version = NULL,
  species,
  target_species
) {
  resp <- httr2::request(.construct_versioned_url(version)) |>
    httr2::req_url_path(sprintf("/homology/symbol/%s/%s", species, symbol)) |>
    httr2::req_url_query(
      type = "orthologues",
      sequence = "none",
      target_species = target_species,
      `content-type` = "application/json"
    ) |>
    httr2::req_user_agent(REMART_USER_AGENT) |>
    httr2::req_perform() |>
    httr2::resp_body_json(simplifyVector = FALSE)

  resp$data[[1]]$homologies
}
