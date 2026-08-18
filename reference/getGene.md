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
#> Error in res[ids]: invalid subscript type 'list'

ids <- c(
 "ENSG00000003987",
 "ENSG00000004939"
)
remart::getGene(
  id = ids,
  type = "ensembl_gene_id"
)
#> Warning: 'band' column information is not available from the Ensembl REST API, it will be filled with NA values.
#>   ensembl_gene_id hgnc_symbol
#> 1 ENSG00000003987       MTMR7
#> 2 ENSG00000004939      SLC4A1
#>                                                                                description
#> 1                        myotubularin related protein 7 [Source:HGNC Symbol;Acc:HGNC:7454]
#> 2 solute carrier family 4 member 1 (Diego blood group) [Source:HGNC Symbol;Acc:HGNC:11027]
#>   chromosome_name band strand start_position end_position
#> 1               8   NA     -1       17294951     17413528
#> 2              17   NA     -1       44248390     44268162
```
