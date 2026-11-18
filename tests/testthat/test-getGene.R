test_that("single and multiple getGene() calls are identical", {
  multi_call <- getGene(
    id = c("ENSG00000157764", "ENSG00000004939"),
    type = "ensembl_gene_id"
  ) |>
    expect_no_warning()

  single_call_1 <- getGene(
    id = "ENSG00000157764",
    type = "ensembl_gene_id"
  ) |>
    expect_no_warning()

  single_call_2 <- getGene(
    id = "ENSG00000004939",
    type = "ensembl_gene_id"
  ) |>
    expect_no_warning()

  expect_identical(
    multi_call,
    rbind(single_call_1, single_call_2)
  )

  expect_named(
    multi_call,
    c(
      "ensembl_gene_id",
      "hgnc_symbol",
      "description",
      "chromosome_name",
      "band",
      "strand",
      "start_position",
      "end_position"
    )
  )
})

test_that("getGene() works with gene symbols", {
  res <- getGene(
    id = c("APOE", "MAPT"),
    type = "external_gene_name",
    species = "human",
    version = "oct2024"
  ) |>
    expect_no_warning()

  expect_named(
    res,
    c(
      "ensembl_gene_id",
      "hgnc_symbol",
      "description",
      "chromosome_name",
      "band",
      "strand",
      "start_position",
      "end_position"
    )
  )
})

test_that("getGene() fails with unsupported ID types", {
  expect_error(
    getGene(
      id = "ENST00000357654",
      type = "unknown_id"
    ),
    "Only Ensembl Gene IDs"
  )
})

test_that("getGene() fills unknown IDs with NA and warns once", {
  local_mocked_bindings(
    .remart_lookup = function(values, ...) {
      setNames(list(NULL, NULL), values)
    },
    .package = "remart"
  )
  expect_warning(
    res <- getGene(id = c("ENSG00000000001", "ENSG00000000002")),
    "not found"
  )
})
