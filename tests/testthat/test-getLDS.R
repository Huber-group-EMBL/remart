test_that("getLDS() works with homologies", {
  res <- getLDS(
    attributes = c("ensembl_gene_id", "hgnc_symbol", "external_gene_name"),
    filters = "ensembl_gene_id",
    values = c("ENSG00000157764", "ENSG00000004939"),
    attributesL = c("ensembl_gene_id"),
    speciesL = "mouse",
    version = "oct2024"
  ) |>
    expect_no_error() |>
    expect_no_warning()

  expect_named(
    res,
    c(
      "ensembl_gene_id",
      "hgnc_symbol",
      "external_gene_name",
      "ensembl_gene_id.1"
    )
  )
})

test_that("getLDS() works with gene symbols", {
  res <- getLDS(
    attributes = c("ensembl_gene_id", "hgnc_symbol", "external_gene_name"),
    filters = "external_gene_name",
    values = c("APOE", "MAPT"),
    species = "human",
    attributesL = c("ensembl_gene_id"),
    speciesL = "mouse",
    version = "oct2024"
  ) |>
    expect_no_error() |>
    expect_no_warning()

  expect_named(
    res,
    c(
      "ensembl_gene_id",
      "hgnc_symbol",
      "external_gene_name",
      "ensembl_gene_id.1"
    )
  )
})

test_that("getLDS() returns an empty data frame with source and target columns when no ID is found", {
  local_mocked_bindings(
    .remart_lookup = function(values, ...) {
      setNames(rep(list(NULL), length(values)), values)
    },
    .package = "remart"
  )
  expect_warning(
    res <- getLDS(
      attributes = c("ensembl_gene_id", "external_gene_name"),
      filters = "ensembl_gene_id",
      values = "ENSG00000000001",
      attributesL = c("ensembl_gene_id", "external_gene_name"),
      speciesL = "mouse"
    ),
    "were not found"
  )
  expect_identical(nrow(res), 0L)
  expect_named(
    res,
    c(
      "ensembl_gene_id",
      "external_gene_name",
      "ensembl_gene_id.1",
      "external_gene_name.1"
    )
  )
})

fake_gene <- function(id, name) {
  list(
    id = id,
    display_name = name,
    species = "homo_sapiens",
    seq_region_name = "1",
    start = 1L,
    end = 10L,
    strand = 1L,
    biotype = "protein_coding",
    description = "desc",
    version = 1L
  )
}

test_that("getLDS() returns an empty data frame when filtersL drops every orthologue", {
  local_mocked_bindings(
    .remart_lookup = function(values, ...) {
      setNames(list(fake_gene("ENSG00000000001", "SRC")), values)
    },
    .remart_homologies_id = function(...) {
      list(list(target = list(id = "ENSMUSG00000000002")))
    },
    .remart_lookup_id = function(ids, ...) {
      setNames(list(fake_gene("ENSMUSG00000000002", "Tgt")), ids)
    },
    .package = "remart"
  )
  res <- getLDS(
    attributes = c("ensembl_gene_id", "external_gene_name"),
    filters = "ensembl_gene_id",
    values = "ENSG00000000001",
    attributesL = c("ensembl_gene_id", "external_gene_name"),
    filtersL = "external_gene_name",
    valuesL = "NotPresent",
    speciesL = "mouse"
  )
  expect_identical(nrow(res), 0L)
  expect_named(
    res,
    c(
      "ensembl_gene_id",
      "external_gene_name",
      "ensembl_gene_id.1",
      "external_gene_name.1"
    )
  )
})

test_that("getLDS() keeps the orthologue when filtersL matches", {
  local_mocked_bindings(
    .remart_lookup = function(values, ...) {
      setNames(list(fake_gene("ENSG00000000001", "SRC")), values)
    },
    .remart_homologies_id = function(...) {
      list(list(target = list(id = "ENSMUSG00000000002")))
    },
    .remart_lookup_id = function(ids, ...) {
      setNames(list(fake_gene("ENSMUSG00000000002", "Tgt")), ids)
    },
    .package = "remart"
  )
  res <- getLDS(
    attributes = c("ensembl_gene_id", "external_gene_name"),
    filters = "ensembl_gene_id",
    values = "ENSG00000000001",
    attributesL = c("ensembl_gene_id", "external_gene_name"),
    filtersL = "external_gene_name",
    valuesL = "Tgt",
    speciesL = "mouse"
  )
  expect_identical(nrow(res), 1L)
  expect_identical(res$ensembl_gene_id.1, "ENSMUSG00000000002")
  expect_identical(res$external_gene_name.1, "Tgt")
})

test_that("getLDS() returns the expected mouse orthologue values from fixtures", {
  res <- getLDS(
    attributes = c("ensembl_gene_id", "external_gene_name"),
    filters = "ensembl_gene_id",
    values = "ENSG00000157764",
    attributesL = c("ensembl_gene_id", "external_gene_name"),
    speciesL = "mouse",
    version = "oct2024"
  ) |>
    expect_no_error() |>
    expect_no_warning()

  expect_identical(nrow(res), 1L)
  expect_identical(res$ensembl_gene_id, "ENSG00000157764")
  expect_identical(res$ensembl_gene_id.1, "ENSMUSG00000002413")
  expect_identical(res$external_gene_name.1, "Braf")
})
