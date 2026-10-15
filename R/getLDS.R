#' Retrieve orthologous gene annotations across two species
#'
#' @inheritParams biomaRt::getLDS
#' @param ... Ignored. Used to catch no longer necessary parameters such as
#'   `mart`, `martL`, `verbose`, `uniqueRows` and `bmHeader` from
#'   \pkg{biomaRt} functions.
#' @inheritParams getBM species version
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
#' Only `"ensembl_gene_id"` and `"external_gene_name"` are supported for `filter`.
#'
#' @returns A data frame containing source-species and target-species
#'   ortholog annotations.
#'
#' @export
#'
#' @examples
#' \donttest{
#' getLDS(
#'   attributes = c("ensembl_gene_id", "external_gene_name"),
#'   filters = "ensembl_gene_id",
#'   values = "ENSG00000157764",
#'   attributesL = c("ensembl_gene_id", "external_gene_name"),
#'   speciesL = "mouse"
#' )
#'
#' # It is also possible to a gene symbol, but a species must be specified, as
#' # gene symbols are not unique across species.
#' getLDS(
#'   attributes = c("ensembl_gene_id", "external_gene_name"),
#'   filters = "external_gene_name",
#'   values = "APOE",
#'   species = "human",
#'   attributesL = c("ensembl_gene_id", "external_gene_name"),
#'   speciesL = "mouse"
#' )
#'
#' # Query a specific Ensembl release for the source and target genes.
#' getLDS(
#'   attributes = c("ensembl_gene_id", "external_gene_name"),
#'   filters = "ensembl_gene_id",
#'   values = "ENSG00000157764",
#'   attributesL = c("ensembl_gene_id", "external_gene_name"),
#'   speciesL = "mouse",
#'   version = 114
#' )
#' }
getLDS <- function(
  attributes,
  filters = "",
  values = "",
  attributesL,
  filtersL = "",
  valuesL = "",
  ...,
  version = NULL,
  species = NULL,
  speciesL = NULL
) {
  stopifnot(
    is.character(attributes),
    is.character(filters),
    is.character(values),
    is.character(attributesL),
    is.character(filtersL),
    is.character(valuesL),
    is.null(species) || is.character(species),
    is.character(speciesL)
  )

  # TODO: add support for transcript-level attributes
  ensembl_ids <- "ensembl_gene_id"
  supported_filters <- c(ensembl_ids, "external_gene_name")
  supported_attributes <- .listGeneLevelAttributes()

  if (length(filters) != 1L || filters %notin% supported_filters) {
    stop(
      "Only a single filter is supported at the moment, and must be one of: ",
      toString(supported_filters)
    )
  }
  if (filters %notin% ensembl_ids && is.null(species)) {
    stop(
      "The `species` argument must be provided when using filters other than ",
      toString(ensembl_ids)
    )
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

  source_genes <- .remart_lookup(
    values = values,
    filters = filters,
    version = version,
    species = species,
    expand = FALSE
  )

  missing_ids <- values[lengths(source_genes[values]) == 0]
  if (length(missing_ids) > 0) {
    warning(
      "The following identifiers were not found and will be ignored: ",
      toString(missing_ids)
    )
  }
  found_ids <- setdiff(values, missing_ids)

  homologies_by_id <- lapply(found_ids, function(id) {
    switch(
      filters,
      "ensembl_gene_id" = .remart_homologies_id(
        id,
        version = version,
        species = source_genes[[id]]$species,
        target_species = speciesL
      ),
      "external_gene_name" = .remart_homologies_symbol(
        id,
        version = version,
        species = species,
        target_species = speciesL
      )
    )
  }) |>
    setNames(found_ids)

  # Single batched lookup for all target genes
  target_ids <- homologies_by_id |>
    unlist(recursive = FALSE) |>
    vapply(function(h) h$target$id, character(1)) |>
    unique()

  target_genes <- if (length(target_ids) > 0) {
    .remart_lookup_id(target_ids, version = version, expand = FALSE)
  } else {
    list()
  }

  rows <- lapply(found_ids, function(id) {
    gene <- source_genes[[id]]

    lapply(homologies_by_id[[id]], function(h) {
      target_gene <- target_genes[[h$target$id]]

      if (nzchar(filtersL)) {
        filter_value <- .remart_bm_attr(filtersL, gene = target_gene)
        if (filter_value %notin% valuesL) {
          return(NULL)
        }
      }

      row_source <- .remart_bm_row(attributes, gene = gene)
      row_target <- .remart_bm_row(attributesL, gene = target_gene)

      data.frame(row_source, row_target)
    }) |>
      do.call(rbind, args = _)
  })

  df <- do.call(rbind, rows)

  if (NROW(df) == 0) {
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
