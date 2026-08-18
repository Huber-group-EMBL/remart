# Retrieve gene/transcript annotations from Ensembl

Retrieve gene/transcript annotations from Ensembl

## Usage

``` r
getBM(attributes, filters = "", values = "", ..., species = NULL)
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

- species:

  Ensembl name (e.g. `"mouse"` or `"mus_musculus"`) of the species to
  look Ensembl IDs for if, e.g., `external_gene_name` is provided in
  `filters`. In biomaRt, this was inferred from the `mart` argument, but
  since this argument is no longer used, the species must be provided
  explicitly.

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
`ensembl_transcript_id`, `external_gene_name`.

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
#>   ensembl_gene_id external_gene_name chromosome_name
#> 1 ENSG00000157764               BRAF               7
#> 2 ENSG00000004939             SLC4A1              17

# It is also possible to a gene symbol, but a species must be specified, as
# gene symbols are not unique across species.
getBM(
  attributes = attribs,
  filters = "external_gene_name",
  values = c("APOE", "MAPT"),
  species = "human"
)
#>   ensembl_gene_id external_gene_name chromosome_name
#> 1 ENSG00000130203               APOE              19
#> 2 ENSG00000186868               MAPT              17
```
