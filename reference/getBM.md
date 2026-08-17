# Retrieve gene/transcript annotations from Ensembl

Retrieve gene/transcript annotations from Ensembl

## Usage

``` r
getBM(attributes, filters = "", values = "", ...)
```

## Arguments

- attributes:

  Attributes you want to retrieve. A possible list of attributes can be
  retrieved using the function
  [`listAttributes()`](https://huber-group-embl.github.io/remart/reference/listAttributes.md).

- filters:

  Filters (one or more) that should be used in the query. A possible
  list of filters can be retrieved using the function `listFilters()`.

- values:

  Values of the filter, e.g. vector of affy IDs. If multiple filters are
  specified then the argument should be a list of vectors of which the
  position of each vector corresponds to the position of the filters in
  the filters argument.

- ...:

  Ignored. Used to catch no longer necessary parameters such as `mart`,
  `checkFilters`, `verbose`, `uniqueRows`, `bmHeader`, `quote` and
  `useCache` from biomaRt functions.

## Value

A data frame containing the requested gene or transcript annotations,
with one column for each requested attribute. The number of rows does
not necessarily match the number of requested identifiers, as some
attributes can have multiple values for a single identifier (e.g. a gene
with multiple transcripts).

## Details

Only a subset of the attributes and filters supported by the `biomaRt`
package are currently implemented, as this data has to be retrieved
through the Ensembl REST `lookup/id` endpoint rather than a generic
BioMart query engine.

Supported filters (only one can be used at a time): `ensembl_gene_id`,
`ensembl_transcript_id`.

Supported attributes: `ensembl_gene_id`, `ensembl_transcript_id`,
`ensembl_peptide_id`, `external_gene_name`, `description`,
`chromosome_name`, `start_position`, `end_position`, `strand`,
`gene_biotype`, `transcript_biotype`, `version`.

## Examples

``` r
attribs <- c("ensembl_gene_id", "external_gene_name", "chromosome_name")
getBM(
  attributes = attribs,
  filters = "ensembl_gene_id",
  values = c("ENSG00000157764", "ENSG00000004939")
)
#> Error in httr2::req_perform(httr2::req_body_json(httr2::req_user_agent(httr2::req_method(httr2::req_url_path(httr2::request("https://rest.ensembl.org"),     "/lookup/id"), "POST"), REMART_USER_AGENT), list(ids = as.list(ids),     expand = as.integer(expand)))): HTTP 503 Service Unavailable.
```
