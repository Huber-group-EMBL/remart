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
#> 1               7   NA     -1      140719327    140924976

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
#> 1 ENSG00000004939      SLC4A1
#> 2 ENSG00000003987       MTMR7
#>                                                                                description
#> 1 solute carrier family 4 member 1 (Diego blood group) [Source:HGNC Symbol;Acc:HGNC:11027]
#> 2                        myotubularin related protein 7 [Source:HGNC Symbol;Acc:HGNC:7454]
#>   chromosome_name band strand start_position end_position
#> 1              17   NA     -1       44248390     44268141
#> 2               8   NA     -1       17296794     17413528
```
