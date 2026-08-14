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
#>    ensembl_gene_id external_gene_name chromosome_name
#> 1  ENSG00000157764               BRAF               7
#> 2  ENSG00000157764               BRAF               7
#> 3  ENSG00000157764               BRAF               7
#> 4  ENSG00000157764               BRAF               7
#> 5  ENSG00000157764               BRAF               7
#> 6  ENSG00000157764               BRAF               7
#> 7  ENSG00000157764               BRAF               7
#> 8  ENSG00000157764               BRAF               7
#> 9  ENSG00000157764               BRAF               7
#> 10 ENSG00000157764               BRAF               7
#> 11 ENSG00000157764               BRAF               7
#> 12 ENSG00000157764               BRAF               7
#> 13 ENSG00000157764               BRAF               7
#> 14 ENSG00000157764               BRAF               7
#> 15 ENSG00000157764               BRAF               7
#> 16 ENSG00000157764               BRAF               7
#> 17 ENSG00000157764               BRAF               7
#> 18 ENSG00000157764               BRAF               7
#> 19 ENSG00000157764               BRAF               7
#> 20 ENSG00000157764               BRAF               7
#> 21 ENSG00000157764               BRAF               7
#> 22 ENSG00000157764               BRAF               7
#> 23 ENSG00000157764               BRAF               7
#> 24 ENSG00000157764               BRAF               7
#> 25 ENSG00000157764               BRAF               7
#> 26 ENSG00000157764               BRAF               7
#> 27 ENSG00000157764               BRAF               7
#> 28 ENSG00000157764               BRAF               7
#> 29 ENSG00000157764               BRAF               7
#> 30 ENSG00000157764               BRAF               7
#> 31 ENSG00000157764               BRAF               7
#> 32 ENSG00000157764               BRAF               7
#> 33 ENSG00000157764               BRAF               7
#> 34 ENSG00000157764               BRAF               7
#> 35 ENSG00000157764               BRAF               7
#> 36 ENSG00000004939             SLC4A1              17
#> 37 ENSG00000004939             SLC4A1              17
#> 38 ENSG00000004939             SLC4A1              17
#> 39 ENSG00000004939             SLC4A1              17
#> 40 ENSG00000004939             SLC4A1              17
#> 41 ENSG00000004939             SLC4A1              17
```
