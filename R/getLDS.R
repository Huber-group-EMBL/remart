#' Retrieve orthologous gene annotations across two species
#'
#' @inheritParams biomaRt::getLDS
#' @param ... Ignored. Used to catch no longer necessary parameters such as
#'   `mart`, `martL`, `verbose`, `uniqueRows` and `bmHeader` from
#'   \pkg{biomaRt} functions.
#' @param speciesL Ensembl name (e.g. `"mouse"` or `"mus_musculus"`) of the
#'   species to look up orthologues in. This replaces the `martL` argument
#'   used in \pkg{biomaRt}, as connections to Ensembl datasets are no longer
#'   needed, but the species of the linked dataset can not be inferred from
#'   `attributesL`/`filtersL`/`valuesL` alone.
#'
#' @details
#' This function relies on the Ensembl REST `homology/id` endpoint, and
#' therefore only supports retrieving orthologues, and not the more general
#' cross-database attribute linking `biomaRt::getLDS()` could perform.
#'
#' Supported filters/attributes (for both `filters`/`attributes` and
#' `filtersL`/`attributesL`): `ensembl_gene_id`, `ensembl_peptide_id`,
#' `external_gene_name`, `description`, `chromosome_name`,
#' `start_position`, `end_position`, `strand`, `gene_biotype`.
#'
#' Only `filters = "ensembl_gene_id"` is supported.
#'
#' @returns A data frame containing source-species and target-species
#'   ortholog annotations.
#'
#' @export
#'
#' @examples
#' getLDS(
#'   attributes = c("ensembl_gene_id", "external_gene_name"),
#'   filters = "ensembl_gene_id",
#'   values = "ENSG00000157764",
#'   attributesL = c("ensembl_gene_id", "external_gene_name"),
#'   speciesL = "mouse"
#' )
getLDS <- function(
  attributes,
  filters = "",
  values = "",
  attributesL,
  filtersL = "",
  valuesL = "",
  ...,
  speciesL = NULL
) {
  stopifnot(
    is.character(attributes),
    is.character(filters),
    is.character(values),
    is.character(attributesL),
    is.character(filtersL),
    is.character(valuesL),
    is.character(speciesL)
  )

  # TODO: add support for transcript-level attributes
  supported_attributes <- .listGeneLevelAttributes()

  if (length(filters) != 1 || filters != "ensembl_gene_id") {
    stop('Only filters = "ensembl_gene_id" is supported at the moment.')
  }

  if (length(filtersL) != 1 || filtersL %notin% c("", supported_attributes)) {
    stop(
      'filtersL must be the empty string "" or one of: ',
      toString(supported_attributes)
    )
  }

  unsupported_attributes <- setdiff(
    c(attributes, attributesL),
    supported_attributes
  )
  if (length(unsupported_attributes) > 0) {
    stop(
      "Unsupported attribute(s): ",
      toString(unsupported_attributes),
      ". Supported attributes are: ",
      toString(supported_attributes)
    )
  }

  if (missing(speciesL) || length(speciesL) != 1 || speciesL == "") {
    stop(
      '`speciesL` (e.g. "mouse" or "mus_musculus"), identifying the ',
      "target species, must be provided. It replaces the `martL` argument ",
      "used in biomaRt."
    )
  }

  values <- values[nzchar(values)]
  if (length(values) == 0) {
    stop("`values` must contain at least one identifier.")
  }

  source_genes <- .remart_lookup_id(values, expand = FALSE)

  missing_ids <- values[vapply(source_genes, is.null, logical(1))]
  if (length(missing_ids) > 0) {
    warning(
      "The following identifiers were not found and will be ignored: ",
      toString(missing_ids)
    )
  }

  rows <- lapply(values, function(id) {
    gene <- source_genes[[id]]
    if (is.null(gene)) {
      return(NULL)
    }

    homologies <- .remart_homologies(
      id,
      species = gene$species,
      target_species = speciesL
    )
    if (length(homologies) == 0) {
      return(NULL)
    }

    target_ids <- vapply(homologies, function(h) h$target$id, character(1))
    target_genes <- .remart_lookup_id(target_ids, expand = FALSE)

    lapply(homologies, function(h) {
      target_gene <- target_genes[[h$target$id]]

      if (nzchar(filtersL)) {
        filter_value <- .remart_bm_attr(filtersL, gene = target_gene)
        if (filter_value %notin% valuesL) {
          return(NULL)
        }
      }

      row_source <- .remart_bm_row(attributes, gene = gene)
      if ("ensembl_peptide_id" %in% attributes) {
        row_source$ensembl_peptide_id <- h$source$protein_id %||% NA_character_
      }

      row_target <- .remart_bm_row(attributesL, gene = target_gene)
      if ("ensembl_peptide_id" %in% attributesL) {
        row_target$ensembl_peptide_id <- h$target$protein_id %||% NA_character_
      }

      data.frame(row_source, row_target)
    }) |>
      do.call(rbind, args = _)
  })

  df <- do.call(rbind, rows)

  if (nrow(df) == 0) {
    # Empty df but with the expected columns.
    # Having a stable output format makes it easier to post-process.
    empty_df <- vector("list", length(attributes)) |>
      setNames(attributes) |>
      list2DF()
    return(empty_df)
  }

  rownames(df) <- NULL
  return(df)
}
