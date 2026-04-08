# Get Sequences from Ensembl

Get Sequences from Ensembl

## Usage

``` r
getSequence(
  chromosome,
  start,
  end,
  id,
  type,
  seqType,
  upstream,
  downstream,
  ...
)
```

## Arguments

- chromosome:

  Chromosome name

- start:

  start position of sequence on chromosome

- end:

  end position of sequence on chromosome

- id:

  An identifier or vector of identifiers.

- type:

  The type of identifier used. Supported types are hugo, ensembl, embl,
  entrezgene, refseq, ensemblTrans and unigene. Alternatively one can
  also use a filter to specify the type. Possible filters are given by
  the `listFilters()` function.

- seqType:

  Type of sequence that you want to retrieve. Allowed seqTypes are given
  in the details section.

- upstream:

  To add the upstream sequence of a specified number of basepairs to the
  output.

- downstream:

  To add the downstream sequence of a specified number of basepairs to
  the output.

- ...:

  Ignored. Used to catch no longer necessary parameters such as `mart`
  from biomaRt functions.

## Examples

``` r
remart::getSequence(
  seqType = "gene_exon_intron",
  type = "ensembl_gene_id",
  id = "ENSG00000001497"
)
#> Error in type %notin% c("ensembl_gene_id", "ensembl_transcript_id"): could not find function "%notin%"

ids <- c(
 "ENSG00000003987",
 "ENSG00000004939"
)
remart::getSequence(
  seqType = "gene_exon_intron",
  type = "ensembl_gene_id",
  id = ids
)
#> Error in type %notin% c("ensembl_gene_id", "ensembl_transcript_id"): could not find function "%notin%"
```
