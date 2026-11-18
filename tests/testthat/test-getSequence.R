test_that("single and multiple getSequence() calls are identical", {
  multi_call <- getSequence(
    seqType = "gene_exon_intron",
    type = "ensembl_gene_id",
    id = c("ENSG00000157764", "ENSG00000004939")
  ) |>
    expect_no_error() |>
    expect_no_warning()

  single_call_1 <- getSequence(
    seqType = "gene_exon_intron",
    type = "ensembl_gene_id",
    id = "ENSG00000157764"
  ) |>
    expect_no_error() |>
    expect_no_warning()
  single_call_2 <- getSequence(
    seqType = "gene_exon_intron",
    type = "ensembl_gene_id",
    id = "ENSG00000004939"
  )

  expect_identical(
    multi_call,
    rbind(single_call_1, single_call_2)
  )

  expect_setequal(
    multi_call$query,
    c("ENSG00000157764", "ENSG00000004939")
  )

  expect_match(
    multi_call$id,
    "^ENSG"
  )
})

test_that("getSequence() can return peptide sequence", {
  peptide_seq <- getSequence(
    seqType = "peptide",
    type = "ensembl_gene_id",
    id = "ENSG00000157764",
    version = "may2024"
  ) |>
    expect_no_error() |>
    expect_no_warning()

  expect_all_equal(
    peptide_seq$query,
    "ENSG00000157764"
  )

  expect_match(
    peptide_seq$id,
    "^ENSP"
  )
})

test_that("getSequence() fails with unsupported inputs", {
  expect_error(
    getSequence(
      seqType = "gene_exon_intron",
      type = "unknown_id",
      id = "ENSG00000157764"
    ),
    "Only Ensembl IDs"
  )

  expect_error(
    getSequence(
      seqType = "unknown_seq_type",
      type = "ensembl_gene_id",
      id = "ENSG00000157764"
    ),
    "Invalid seqType"
  )
})

test_that("getSequence() fails with unsupported chromosome input", {
  expect_error(
    getSequence(
      chromosome = "7",
      start = 140719327,
      end = 140925199,
      seqType = "gene_exon_intron",
      type = "ensembl_gene_id",
      id = "ENSG00000157764"
    ),
    "Not implemented yet"
  )
})
