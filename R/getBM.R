#' Retrieve gene/transcript annotations from Ensembl
#'
#' @inheritParams biomaRt::getBM
#' @param ... Ignored. Used to catch no longer necessary parameters such as
#'   `mart`, `checkFilters`, `verbose`, `uniqueRows`, `bmHeader`, `quote` and
#'   `useCache` from \pkg{biomaRt} functions.
#' @param species Ensembl name (e.g. `"mouse"` or `"mus_musculus"`) of the
#'   species to look Ensembl IDs for if, e.g., `external_gene_name` is provided
#'   in `filters`. In \pkg{biomaRt}, this was inferred from the `mart`
#'   argument, but since this argument is no longer used, the species must be
#'   provided explicitly.
#'
#' @details
#' Only a subset of the attributes and filters supported by the `biomaRt`
#' package are currently implemented, as this data has to be retrieved
#' through the Ensembl REST `lookup/id` endpoint rather than a generic
#' BioMart query engine.
#'
#' Supported filters (only one can be used at a time): `ensembl_gene_id`,
#' `ensembl_transcript_id`.
#'
#' Supported attributes: `ensembl_gene_id`, `ensembl_transcript_id`,
#' `ensembl_peptide_id`, `external_gene_name`, `description`,
#' `chromosome_name`, `start_position`, `end_position`, `strand`,
#' `gene_biotype`, `transcript_biotype`, `version`.
#'
#' @returns A data frame containing the requested gene or transcript
#'   annotations, with one column for each requested attribute.
#'   The number of rows does not necessarily match the number of
#'   requested identifiers, as some attributes can have multiple values
#'   for a single identifier (e.g. a gene with multiple transcripts).
#'
#' @export
#'
#' @examples
#' attribs <- c("ensembl_gene_id", "external_gene_name", "chromosome_name")
#' getBM(
#'   attributes = attribs,
#'   filters = "ensembl_gene_id",
#'   values = c("ENSG00000157764", "ENSG00000004939")
#' )
getBM <- function(
  attributes,
  filters = "",
  values = "",
  ...,
  species = NULL
) {
  stopifnot(
    is.character(attributes),
    is.character(filters),
    is.character(values),
    is.null(species) || is.character(species)
  )

  ensembl_ids <- c("ensembl_gene_id", "ensembl_transcript_id")
  supported_filters <- c(ensembl_ids, "external_gene_name")
  transcript_level_attributes <- .listTranscriptLevelAttributes()
  supported_attributes <- listAttributes()

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

  unsupported_attributes <- setdiff(attributes, supported_attributes)
  if (length(unsupported_attributes) > 0L) {
    stop(
      "Unsupported attribute(s): ",
      toString(unsupported_attributes),
      ".\nSupported attributes are: ",
      toString(supported_attributes),
      ".\nPlease file an issue at ",
      "https://github.com/Huber-group-EMBL/remart/issues",
      " if you would like us to add support for new attributes."
    )
  }

  values <- values[nzchar(values)]
  if (length(values) == 0L) {
    stop("`values` must contain at least one identifier.")
  }

  has_transcript_attributes <- any(
    attributes %notin% .listGeneLevelAttributes()
  )

  ids <- switch(
    filters,
    "ensembl_gene_id" = .remart_lookup_id(
      values,
      expand = has_transcript_attributes
    ),
    "ensembl_transcript_id" = .remart_lookup_id(values, expand = TRUE),
    "external_gene_name" = .remart_lookup_symbol(
      values,
      species = species,
      expand = has_transcript_attributes
    )
  )

  missing_ids <- values[lengths(ids) == 0L]
  if (length(missing_ids) > 0L) {
    warning(
      "The following identifiers were not found and will be ignored: ",
      toString(missing_ids)
    )
  }

  if (filters %in% c("ensembl_gene_id", "external_gene_name")) {
    rows <- lapply(ids, function(gene) {
      if (is.null(gene)) {
        return(NULL)
      }
      transcripts <- gene$Transcript
      if (!has_transcript_attributes || is.null(transcripts)) {
        .remart_bm_row(attributes, gene = gene)
      } else {
        lapply(
          transcripts,
          function(x) .remart_bm_row(attributes, gene = gene, transcript = x)
        ) |>
          do.call(rbind, args = _)
      }
    })
  } else {
    needs_genes <- any(attributes %notin% transcript_level_attributes)
    gene_ids <- unique(unlist(lapply(ids, `[[`, "Parent")))
    genes <- if (needs_genes) {
      .remart_lookup_id(gene_ids, expand = FALSE)
    } else {
      list()
    }

    rows <- lapply(ids, function(transcript) {
      if (is.null(transcript)) {
        return(NULL)
      }
      gene <- if (needs_genes) genes[[transcript$Parent]] else NULL
      .remart_bm_row(attributes, gene = gene, transcript = transcript)
    })
  }

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

#' Build a single-row data.frame of `attributes` from parsed lookup/id objects
#' @noRd
.remart_bm_row <- function(attributes, gene = NULL, transcript = NULL) {
  values <- lapply(
    attributes,
    .remart_bm_attr,
    gene = gene,
    transcript = transcript
  )
  names(values) <- attributes
  list2DF(values)
}

#' Extract the value of a single `biomaRt`-style attribute from parsed
#' `lookup/id` objects
#' @noRd
.remart_bm_attr <- function(attr, gene = NULL, transcript = NULL) {
  translation <- transcript$Translation
  main <- gene %||% transcript

  switch(
    attr,
    ensembl_gene_id = gene$id %||% transcript$Parent %||% NA_character_,
    ensembl_transcript_id = transcript$id %||% NA_character_,
    ensembl_peptide_id = translation$id %||% NA_character_,
    external_gene_name = gene$display_name %||% NA_character_,
    description = gene$description %||% NA_character_,
    chromosome_name = main$seq_region_name %||% NA_character_,
    start_position = main$start %||% NA_integer_,
    end_position = main$end %||% NA_integer_,
    strand = main$strand %||% NA_integer_,
    gene_biotype = gene$biotype %||% NA_character_,
    hgnc_symbol = gene$display_name %||% NA_character_,
    transcript_biotype = transcript$biotype %||% NA_character_,
    version = (transcript %||% gene)$version %||% NA_integer_,
    stop("Unsupported attribute: ", attr)
  )
}
