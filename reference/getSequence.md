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

## Value

A data frame containing the requested sequences and their associated
metadata.

## Examples

``` r
remart::getSequence(
  seqType = "gene_exon_intron",
  type = "ensembl_gene_id",
  id = "ENSG00000001497"
)
#> Error in httr2::req_perform(httr2::req_body_json(httr2::req_user_agent(httr2::req_method(httr2::req_url_path(httr2::request("https://rest.ensembl.org/"),     "sequence/id"), "POST"), REMART_USER_AGENT), req)): HTTP 500 Internal Server Error.

ids <- c(
 "ENSG00000003987",
 "ENSG00000004939"
)
remart::getSequence(
  seqType = "gene_exon_intron",
  type = "ensembl_gene_id",
  id = ids
)
#> Error in httr2::req_perform(httr2::req_body_json(httr2::req_user_agent(httr2::req_method(httr2::req_url_path(httr2::request("https://rest.ensembl.org/"),     "sequence/id"), "POST"), REMART_USER_AGENT), req)): HTTP 500 Internal Server Error.
```
