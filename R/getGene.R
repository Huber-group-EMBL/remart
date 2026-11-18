#' Retrieves gene annotation information from Ensembl
#'
#' @param id Character vector of gene identifiers to annotate.
#' @param type Type of identifier given in `id`. Either `"ensembl_gene_id"`
#'   (the default) or `"external_gene_name"`; no other `biomaRt` identifier
#'   types are supported.
#' @param ... Ignored. Used to catch no longer necessary parameters such as
#'   `mart` from \pkg{biomaRt} functions.
#' @inheritParams getBM species version
#'
#' @returns A data frame containing the following gene annotations for the
#'   requested IDs that returned results:
#'   - `ensembl_gene_id`
#'   - `hgnc_symbol`
#'   - `description`
#'   - `chromosome_name`
#'   - `band` (not available from Ensembl REST API, filled with NA)
#'   - `strand`
#'   - `start_position`
#'   - `end_position`
#' IDs that didn't return results are not be included in the data frame,
#' and a warning listing them is issued.
#'
#' @export
#'
#' @examples
#' getGene(
#'   "ENSG00000157764",
#'   type = "ensembl_gene_id"
#' )
#'
#' \donttest{
#' ids <- c(
#'  "ENSG00000003987",
#'  "ENSG00000004939"
#' )
#' getGene(
#'   id = ids,
#'   type = "ensembl_gene_id",
#'   version = "may2025"
#' )
#' }
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
    base_url = .construct_versioned_url(version),
    species = species,
    expand = FALSE
  )

  was_not_found <- lengths(res) == 0L
  if (any(was_not_found)) {
    missing_ids <- id[was_not_found]
    warning(
      "The following identifiers were not found: ",
      toString(missing_ids),
      call. = FALSE
    )
  }
  df <- lapply(res[!was_not_found], function(x) {
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

  if (NROW(df) == 0L) {
    df <- data.frame(
      ensembl_gene_id = character(),
      hgnc_symbol = character(),
      description = character(),
      chromosome_name = character(),
      band = character(),
      strand = integer(),
      start_position = integer(),
      end_position = integer()
    )
  }

  rownames(df) <- NULL

  return(df)
}
