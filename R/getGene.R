#' Retries gene annotation information from Ensembl.
#' 
#' @inheritParams biomaRt::getGene
#' 
#' @export
#' 
#' @examples
#' remart::getGene(
#'   "ENSG00000157764",
#'   type = "ensembl_gene_id"
#' )
#' 
#' ids <- c(
#'  "ENSG00000003987",
#'  "ENSG00000004939"
#' )
#' remart::getGene(
#'   id = ids,
#'   type = "ensembl_gene_id"
#' )
getGene <- function(
  id,
  type = "ensembl_gene_id",
  mart
) {
  if (type != "ensembl_gene_id") {
    stop("Only Ensembl Gene IDs (ENS...) are supported at the moment")
  }
  if (!is.list(id) && length(id) == 1) {
    id <- list(id)
  }

  res <- httr2::request("https://rest.ensembl.org") |> 
    httr2::req_url_path("/lookup/id/") |>
    httr2::req_method("POST") |>
    httr2::req_user_agent("remart R package") |>
    httr2::req_body_json(list(ids = id)) |>
    httr2::req_perform() |> 
    httr2::resp_body_json(simplify = TRUE)
  
  warning("'band' column information is not available from the Ensembl REST API, it will be filled with NA values.")
  df <- lapply(res, function(x) {
    data.frame(
      ensembl_gene_id = x$id,
      hgnc_symbol = x$display_name,
      description = x$description,
      chromosome_name = x$seq_region_name,
      band = NA,
      strand = x$strand,
      start_position = x$start,
      end_position = x$end
    )
  }) |> 
    do.call(rbind, args = _)
  
  rownames(df) <- NULL

  return(df)
}

