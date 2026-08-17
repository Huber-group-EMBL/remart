# Retries gene annotation information from Ensembl.

Retries gene annotation information from Ensembl.

## Usage

``` r
getGene(id, type = "ensembl_gene_id", ...)
```

## Arguments

- id:

  vector of gene identifiers one wants to annotate

- type:

  type of identifier, possible values can be obtained by the listFilters
  function. Examples are entrezgene_id, hgnc_symbol (for hugo gene
  symbol), ensembl_gene_id, unigene, agilentprobe, affy_hg_u133_plus_2,
  refseq_dna, etc.

- ...:

  Ignored. Used to catch no longer necessary parameters such as `mart`
  from biomaRt functions.

## Value

A data frame containing the following gene annotations for the requested
IDs:

- `ensembl_gene_id`

- `hgnc_symbol`

- `description`

- `chromosome_name`

- `band` (not available from Ensembl REST API, will be filled with NA)

- `strand`

- `start_position`

- `end_position`

## Examples

``` r
remart::getGene(
  "ENSG00000157764",
  type = "ensembl_gene_id"
)
#> Warning: 'band' column information is not available from the Ensembl REST API, it will be filled with NA values.
#>   ensembl_gene_id hgnc_symbol
#> 1 ENSG00000157764        BRAF
#>                                                                        description
#> 1 B-Raf proto-oncogene, serine/threonine kinase [Source:HGNC Symbol;Acc:HGNC:1097]
#>   chromosome_name band strand start_position end_position
#> 1               7   NA     -1      140719327    140925199

ids <- c(
 "ENSG00000003987",
 "ENSG00000004939"
)
remart::getGene(
  id = ids,
  type = "ensembl_gene_id"
)
#> Error in httr2::req_perform(httr2::req_body_json(httr2::req_user_agent(httr2::req_method(httr2::req_url_path(httr2::request("https://rest.ensembl.org"),     "/lookup/id"), "POST"), REMART_USER_AGENT), list(ids = as.list(ids),     expand = as.integer(expand)))): HTTP 500 Internal Server Error.
```
