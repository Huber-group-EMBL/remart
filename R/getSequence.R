#' Get Sequences from Ensembl
#'
#' @param chromosome,start,end Genomic coordinates to retrieve a sequence
#'   from. Not supported yet: supplying `chromosome` currently stops with an
#'   error, so sequences must be requested by `id`.
#' @param id An identifier or vector of identifiers, of the kind given in
#'   `type`.
#' @param type The type of identifier given in `id`. Supported types are
#'   `"ensembl_gene_id"`, `"ensembl_transcript_id"` and
#'   `"ensembl_peptide_id"`.
#' @param seqType Type of sequence to retrieve. One of
#'   `"gene_exon_intron"`, `"cdna"` or `"peptide"`.
#' @param upstream,downstream Number of base pairs of upstream
#'   (`upstream`) or downstream (`downstream`) sequence to add to the output.
#' @param ... Ignored. Used to catch no longer necessary parameters such as
#'   `mart`, `useCache` and `verbose` from \pkg{biomaRt} functions.
#' @inheritParams getBM version
#'
#' @details
#' Sequences are retrieved from the Ensembl REST `sequence/id` endpoint, rather
#' than from a BioMart dataset. This has two consequences: only Ensembl stable
#' IDs can be used to identify features, and genomic coordinates
#' (`chromosome`/`start`/`end`) are not supported yet. Supplying `chromosome`
#' stops with an error; use `biomaRt::getSequence()` if you need it.
#'
#' `type` must be one of:
#'   - `"ensembl_gene_id"`: retrieve the sequence(s) associated with a gene ID,
#'   - `"ensembl_transcript_id"`: retrieve the sequence of a transcript ID,
#'   - `"ensembl_peptide_id"`: retrieve the sequence of a peptide ID.
#'
#' `seqType` must be one of:
#'   - `"gene_exon_intron"`: the genomic sequence, introns included
#'     (`molecule` is `"dna"`),
#'   - `"cdna"`: the cDNA sequence, i.e. the exons spliced together
#'     (`molecule` is `"dna"`),
#'   - `"peptide"`: the protein sequence (`molecule` is `"protein"`).
#'
#' @returns A data frame with one row per returned sequence, and the following
#'   columns:
#'   - `query`: the identifier that was requested, as given in `id`,
#'   - `id`: the Ensembl stable ID of the sequence that was returned (e.g. the
#'     peptide ID when `type = "ensembl_gene_id"` and `seqType = "peptide"`),
#'   - `seq`: the sequence itself, as a single string,
#'   - `desc`: the description of the feature, typically its genomic location
#'     (e.g. `"chromosome:GRCh38:7:140719327:140925199:-1"`), `NA` when Ensembl
#'     does not provide one,
#'   - `molecule`: `"dna"` or `"protein"`, depending on `seqType`,
#'   - `version`: the version of the returned sequence.
#'
#'   Columns are sorted alphabetically. That order is not part of the API, so
#'   select columns by name.
#'
#' @export
#'
#' @examples
#' getSequence(
#'   seqType = "gene_exon_intron",
#'   type = "ensembl_gene_id",
#'   id = "ENSG00000001497"
#' )
#'
#' \donttest{
#' ids <- c(
#'  "ENSG00000003987",
#'  "ENSG00000004939"
#' )
#' getSequence(
#'   seqType = "gene_exon_intron",
#'   type = "ensembl_gene_id",
#'   id = ids
#' )
#'
#' # Retrieve sequences from a specific Ensembl release.
#' getSequence(
#'   seqType = "cdna",
#'   type = "ensembl_gene_id",
#'   id = "ENSG00000001497",
#'   version = 114
#' )
#' }
getSequence <- function(
  chromosome,
  start,
  end,
  id,
  type,
  seqType,
  upstream,
  downstream,
  ...,
  version = NULL
) {
  if (!missing(chromosome)) {
    stop(
      "Not implemented yet. ",
      "Please request it by opening an issue at ",
      "https://github.com/Huber-group-EMBL/remart/issues. ",
      "For now, please use biomaRt::getSequence().",
      call. = FALSE
    )
  }
  if (missing(id)) {
    stop("`id` must be provided, as sequences are currently retrieved by ID.")
  }
  return(
    .getSequenceFromId(
      id = id,
      type = type,
      seqType = seqType,
      upstream = upstream,
      downstream = downstream,
      version = version
    )
  )
}

.getSequenceFromId <- function(
  id,
  type,
  seqType,
  upstream,
  downstream,
  version = NULL
) {
  if (
    type %notin%
      c("ensembl_gene_id", "ensembl_transcript_id", "ensembl_peptide_id")
  ) {
    stop("Only Ensembl IDs (ENS...) are supported at the moment")
  }
  if (!is.list(id) && length(id) == 1) {
    id <- list(id)
  }

  req <- list(
    ids = id
  )
  if (!missing(upstream)) {
    req$expand_5prime <- upstream
  }
  if (!missing(downstream)) {
    req$expand_3prime <- downstream
  }

  req$type <- switch(
    seqType,
    "gene_exon_intron" = "genomic",
    "cdna" = "cdna",
    "peptide" = "protein", # see example use in DominoEffect package
    stop(
      "Invalid seqType. ",
      "Must be one of 'gene_exon_intron', 'cdna', or 'peptide'."
    )
  )

  res <- httr2::request(.construct_versioned_url(version)) |>
    httr2::req_url_path("/sequence/id") |>
    httr2::req_method("POST") |>
    httr2::req_user_agent(REMART_USER_AGENT) |>
    httr2::req_body_json(req) |>
    httr2::req_perform() |>
    httr2::resp_body_json(simplifyVector = TRUE)

  # The columns are seemingly returned in a random(?)/unstable order.
  res[sort(names(res), method = "radix")]
}
