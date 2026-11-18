test_that("single and multiple getBM() calls are identical", {
  # Gene attributes only
  multi_call <- getBM(
    attributes = c(
      "ensembl_gene_id",
      "external_gene_name",
      "description",
      "chromosome_name",
      "start_position",
      "end_position",
      "strand",
      "gene_biotype",
      "transcript_biotype",
      "version",
      "hgnc_symbol"
    ),
    filters = "ensembl_gene_id",
    values = c("ENSG00000157764", "ENSG00000004939")
  ) |>
    expect_no_error() |>
    expect_no_warning()

  single_call_1 <- getBM(
    attributes = c(
      "ensembl_gene_id",
      "external_gene_name",
      "description",
      "chromosome_name",
      "start_position",
      "end_position",
      "strand",
      "gene_biotype",
      "transcript_biotype",
      "version",
      "hgnc_symbol"
    ),
    filters = "ensembl_gene_id",
    values = "ENSG00000157764"
  ) |>
    expect_no_error() |>
    expect_no_warning()
  single_call_2 <- getBM(
    attributes = c(
      "ensembl_gene_id",
      "external_gene_name",
      "description",
      "chromosome_name",
      "start_position",
      "end_position",
      "strand",
      "gene_biotype",
      "transcript_biotype",
      "version",
      "hgnc_symbol"
    ),
    filters = "ensembl_gene_id",
    values = "ENSG00000004939"
  )

  expect_identical(
    multi_call,
    rbind(single_call_1, single_call_2)
  )
})

test_that("getBM() on gene IDs can return transcript level info", {
  result <- getBM(
    attributes = c(
      "ensembl_gene_id",
      "ensembl_transcript_id",
      "ensembl_peptide_id",
      "external_gene_name",
      "description"
    ),
    filters = "ensembl_gene_id",
    values = c("ENSG00000157764", "ENSG00000004939")
  ) |>
    expect_no_error() |>
    expect_no_warning()

  expect_named(
    result,
    c(
      "ensembl_gene_id",
      "ensembl_transcript_id",
      "ensembl_peptide_id",
      "external_gene_name",
      "description"
    )
  )

  expect_setequal(
    result$ensembl_gene_id,
    c("ENSG00000157764", "ENSG00000004939")
  )
})

test_that("getBM() on transcript IDs can return gene level info", {
  result <- getBM(
    attributes = c(
      "ensembl_transcript_id",
      "ensembl_gene_id",
      "external_gene_name",
      "description"
    ),
    filters = "ensembl_transcript_id",
    values = c("ENST00000357654", "ENST00000450305"),
    version = "oct2024"
  ) |>
    expect_no_error() |>
    expect_no_warning()

  expect_named(
    result,
    c(
      "ensembl_transcript_id",
      "ensembl_gene_id",
      "external_gene_name",
      "description"
    )
  )

  expect_setequal(
    result$ensembl_transcript_id,
    c("ENST00000357654", "ENST00000450305")
  )
})

test_that("getBM() on gene symbols can return gene level info", {
  result <- getBM(
    attributes = c(
      "ensembl_gene_id",
      "external_gene_name",
      "description"
    ),
    filters = "external_gene_name",
    values = c("APOE", "MAPT"),
    species = "human",
    version = "oct2024"
  ) |>
    expect_no_error() |>
    expect_no_warning()

  expect_s3_class(result, "data.frame")
  expect_named(
    result,
    c(
      "ensembl_gene_id",
      "external_gene_name",
      "description"
    )
  )
  expect_setequal(
    result$external_gene_name,
    c("APOE", "MAPT")
  )
})

test_that("getBM() fails with unsupported input", {
  expect_error(
    getBM(
      attributes = c("ensembl_gene_id", "external_gene_name"),
      filters = "unsupported_filter",
      values = c("ENSG00000157764", "ENSG00000004939")
    ),
    "Only a single filter is supported at the moment, and must be one of: ensembl_gene_id, ensembl_transcript_id"
  )

  expect_error(
    getBM(
      attributes = c("ensembl_gene_id", "unsupported_attribute"),
      filters = "ensembl_gene_id",
      values = c("ENSG00000157764", "ENSG00000004939")
    ),
    "Unsupported attribute\\(s\\): unsupported_attribute"
  )

  expect_error(
    getBM(
      attributes = c("ensembl_gene_id", "external_gene_name"),
      filters = "external_gene_name",
      values = c("APOE", "MAPT")
    ),
    "The `species` argument must be provided when using filters other than"
  )
})

test_that("getBM() warns for unknown IDs and keeps rows for valid ones", {
  fake_gene <- list(
    id = "ENSG00000000001",
    display_name = "GENE1",
    description = "desc",
    seq_region_name = "1",
    start = 1L,
    end = 10L,
    strand = 1L,
    biotype = "protein_coding",
    version = 1L
  )
  local_mocked_bindings(
    .remart_lookup = function(values, ...) {
      setNames(list(fake_gene, NULL), values)
    },
    .package = "remart"
  )
  expect_warning(
    res <- getBM(
      attributes = c("ensembl_gene_id", "external_gene_name"),
      filters = "ensembl_gene_id",
      values = c("ENSG00000000001", "ENSG00000000002")
    ),
    "ENSG00000000002"
  )
  expect_identical(nrow(res), 1L)
  expect_identical(res$ensembl_gene_id, "ENSG00000000001")
  expect_identical(res$external_gene_name, "GENE1")
})

test_that("getBM() returns an empty data frame when no ID is found", {
  local_mocked_bindings(
    .remart_lookup = function(values, ...) {
      setNames(rep(list(NULL), length(values)), values)
    },
    .package = "remart"
  )
  expect_warning(
    res <- getBM(
      attributes = c("ensembl_gene_id", "external_gene_name"),
      filters = "ensembl_gene_id",
      values = c("ENSG00000000001", "ENSG00000000002")
    ),
    "were not found"
  )
  expect_s3_class(res, "data.frame")
  expect_identical(nrow(res), 0L)
  expect_named(res, c("ensembl_gene_id", "external_gene_name"))
})

test_that("getBM() returns the expected BRAF annotation values from fixtures", {
  res <- getBM(
    attributes = c(
      "ensembl_gene_id",
      "external_gene_name",
      "chromosome_name",
      "strand"
    ),
    filters = "ensembl_gene_id",
    values = "ENSG00000157764"
  ) |>
    expect_no_error() |>
    expect_no_warning()

  expect_identical(res$ensembl_gene_id, "ENSG00000157764")
  expect_identical(res$external_gene_name, "BRAF")
  expect_identical(res$chromosome_name, "7")
  expect_identical(res$strand, -1L)
})
