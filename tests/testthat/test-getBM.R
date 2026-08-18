skip_on_bioc()
skip_on_ci()
skip_if_offline("rest.ensembl.org")

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
    values = c("ENST00000357654", "ENST00000450305")
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
    species = "human"
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
