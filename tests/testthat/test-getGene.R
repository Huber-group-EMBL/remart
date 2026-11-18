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

test_that(".remart_lookup_symbol() sends one request per lookup batch", {
  symbols <- sprintf("GENE%d", seq_len(.remart_lookup_batch_size + 1L))
  n_requests <- 0L
  local_mocked_bindings(
    .remart_lookup_batch_size = 1000L,
    .package = "remart"
  )
  local_mocked_bindings(
    req_perform = function(req, ...) {
      n_requests <<- n_requests + 1L
      stop("2nd batch reached")
    },
    .package = "httr2"
  )
  expect_error(
    .remart_lookup_symbol(
      symbols,
      base_url = "https://rest.ensembl.org",
      species = "human"
    ),
    "2nd batch reached"
  )
  expect_identical(n_requests, 1L)
})

fake_gene_lookup <- list(
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

test_that("getGene() warns for unknown IDs and keeps rows for valid ones", {
  local_mocked_bindings(
    .remart_lookup = function(values, ...) {
      setNames(list(fake_gene_lookup, NULL), values)
    },
    .package = "remart"
  )
  expect_warning(
    res <- getGene(id = c("ENSG00000000001", "ENSG00000000002")),
    "ENSG00000000002"
  )
  expect_identical(nrow(res), 1L)
  expect_identical(res$ensembl_gene_id, "ENSG00000000001")
  expect_identical(res$hgnc_symbol, "GENE1")
})

test_that("getGene() returns an empty data frame for all unknown IDs", {
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
  expect_s3_class(res, "data.frame")
  expect_identical(nrow(res), 0L)
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
