#' Retries gene annotation information from Ensembl.
#'
#' @inheritParams biomaRt::getGene
#' @param ... Ignored. Used to catch no longer necessary parameters such as
#'   `mart` from \pkg{biomaRt} functions.
#' @inheritParams getBM species
#'
#' @returns A data frame containing the following gene annotations for the
#'   requested IDs:
#'   - `ensembl_gene_id`
#'   - `hgnc_symbol`
#'   - `description`
#'   - `chromosome_name`
#'   - `band` (not available from Ensembl REST API, will be filled with NA)
#'   - `strand`
#'   - `start_position`
#'   - `end_position`
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
  ...,
  version = NULL,
  species = NULL
) {
  if (type %notin% c("ensembl_gene_id", "external_gene_name")) {
    stop(
      "Only Ensembl Gene IDs (ENS...) and external gene names are supported at the moment"
    )
  }
  if (type == "external_gene_name" && is.null(species)) {
    stop(
      "When using external gene names, the species must be specified, as gene symbols are not unique across species."
    )
  }

  res <- .remart_lookup(
    values = id,
    filters = type,
    species = species,
    expand = FALSE
  )

  warning(
    "'band' column information is not available from the Ensembl REST API, ",
    "it will be filled with NA values."
  )
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
