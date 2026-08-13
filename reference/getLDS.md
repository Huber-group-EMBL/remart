# Retrieve orthologous gene annotations across two species

Retrieve orthologous gene annotations across two species

## Usage

``` r
getLDS(
  attributes,
  filters = "",
  values = "",
  attributesL,
  filtersL = "",
  valuesL = "",
  speciesL,
  ...
)
```

## Arguments

- attributes:

  Attributes you want to retrieve of primary dataset. A possible list of
  attributes can be retrieved using the function `listAttributes()`.

- filters:

  Filters that should be used in the query. These filters will be
  applied to primary dataset. A possible list of filters can be
  retrieved using the function `listFilters()`.

- values:

  Values of the filter, e.g. list of affy IDs

- attributesL:

  Attributes of linked dataset that needs to be retrieved

- filtersL:

  Filters to be applied to the linked dataset

- valuesL:

  Values for the linked dataset filters

- speciesL:

  Ensembl name (e.g. `"mouse"` or `"mus_musculus"`) of the species to
  look up orthologues in. This replaces the `martL` argument used in
  biomaRt, as connections to Ensembl datasets are no longer needed, but
  the species of the linked dataset can not be inferred from
  `attributesL`/`filtersL`/`valuesL` alone.

- ...:

  Ignored. Used to catch no longer necessary parameters such as `mart`,
  `martL`, `verbose`, `uniqueRows` and `bmHeader` from biomaRt
  functions.

## Details

This function relies on the Ensembl REST `homology/id` endpoint, and
therefore only supports retrieving orthologues, and not the more general
cross-database attribute linking `biomaRt::getLDS()` could perform.

Supported filters/attributes (for both `filters`/`attributes` and
`filtersL`/`attributesL`): `ensembl_gene_id`, `ensembl_peptide_id`,
`external_gene_name`, `description`, `chromosome_name`,
`start_position`, `end_position`, `strand`, `gene_biotype`.

Only `filters = "ensembl_gene_id"` is supported.

## Examples

``` r
remart::getLDS(
  attributes = c("ensembl_gene_id", "external_gene_name"),
  filters = "ensembl_gene_id",
  values = "ENSG00000157764",
  attributesL = c("ensembl_gene_id", "external_gene_name"),
  speciesL = "mouse"
)
#>   ensembl_gene_id external_gene_name  ensembl_gene_id.1 external_gene_name.1
#> 1 ENSG00000157764               BRAF ENSMUSG00000002413                 Braf
```
