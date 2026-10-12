.construct_versioned_url <- function(version = NULL) {
  if (is.null(version)) {
    return("https://rest.ensembl.org")
  }
  # Backward compatibility with how version was specified in biomaRt
  if (is.numeric(version) || grepl("^[0-9]+$", version)) {
    version <- paste0("e", version)
  }
  url <- sprintf("https://%s.rest.ensembl.org", version)

  # Take into account redirect early to avoid POST params being dropped on
  # redirect
  httr2::request(url) |>
    httr2::req_user_agent(REMART_USER_AGENT) |>
    httr2::req_method("HEAD") |>
    httr2::req_perform() |>
    httr2::resp_url()
}
