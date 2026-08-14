# List supported attributes

List supported attributes

## Usage

``` r
listAttributes(...)
```

## Arguments

- ...:

  Ignored. Used to catch no longer necessary parameters from the biomaRt
  functions.

## Value

A character vector of supported attributes to be used in
[`getBM()`](https://huber-group-embl.github.io/remart/reference/getBM.md)
and
[`getLDS()`](https://huber-group-embl.github.io/remart/reference/getLDS.md).

## Examples

``` r
listAttributes()
#>  [1] "chromosome_name"       "description"           "end_position"         
#>  [4] "ensembl_gene_id"       "ensembl_peptide_id"    "ensembl_transcript_id"
#>  [7] "external_gene_name"    "gene_biotype"          "hgnc_symbol"          
#> [10] "start_position"        "strand"                "transcript_biotype"   
#> [13] "version"              
```
