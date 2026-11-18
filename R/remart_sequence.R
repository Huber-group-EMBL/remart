#' Batch-fetch sequences via the Ensembl REST `sequence/id` endpoint
#'
#' @param ids character vector of Ensembl stable IDs.
#' @param type sequence type understood by the endpoint: `"genomic"`, `"cdna"`
#'   or `"protein"`.
#' @param base_url base URL of the Ensembl REST server.
#' @param extra named list of additional body parameters (e.g.
#'   `expand_5prime`, `expand_3prime`).
#'
#' @returns A data frame with one row per returned sequence, columns sorted
#'   alphabetically.
#'
#' @noRd
.remart_sequence <- function(ids, type, base_url, extra = list()) {
  res <- lapply(
    .remart_batches(ids, .remart_sequence_batch_size),
    function(batch) {
      req <- c(list(ids = as.list(batch), type = type), extra)
      httr2::request(base_url) |>
        httr2::req_url_path("/sequence/id") |>
        httr2::req_method("POST") |>
        httr2::req_user_agent(REMART_USER_AGENT) |>
        httr2::req_body_json(req) |>
        httr2::req_perform() |>
        httr2::resp_body_json(simplifyVector = TRUE)
    }
  ) |>
    unname() |>
    do.call(rbind, args = _)

  # The columns are seemingly returned in a random(?)/unstable order.
  res[sort(names(res), method = "radix")]
}

# Maximum number of IDs Ensembl accepts in a single sequence/id POST body
# (see https://rest.ensembl.org/documentation/info/sequence_id_post).
.remart_sequence_batch_size <- 50L
