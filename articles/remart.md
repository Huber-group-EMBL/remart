# Introduction to remart

## Overview

The *[remart](https://bioconductor.org/packages/3.23/remart)* package
provides a drop-in replacement for
*[biomaRt](https://bioconductor.org/packages/3.23/biomaRt)* workflows.
It keeps familiar function names and signatures while replacing the
BioMart backend with the Ensembl REST API.

*[remart](https://bioconductor.org/packages/3.23/remart)* is not (yet?)
a complete implementation of the BioMart query language. It currently
supports a focused set of gene and transcript annotation queries,
sequence retrieval, and orthologue queries. Interaction with non-Ensembl
Marts should still be done with
*[biomaRt](https://bioconductor.org/packages/3.23/biomaRt)*.

*[remart](https://bioconductor.org/packages/3.23/remart)* should not
only be more stable, faster, but also hopefully more user-friendly than
*[biomaRt](https://bioconductor.org/packages/3.23/biomaRt)*, as many
arguments are no longer necessary. These arguments are silently accepted
for compatibility, but they are ignored.

All annotation and sequence examples in this vignette query live Ensembl
services. They require an internet connection, and results can change as
Ensembl releases and annotations are updated.

## Installation and loading

The development version can be installed from GitHub with:

``` r

pak::pak("Huber-group-EMBL/remart")
```

Load the package in an R session with:

``` r

library(remart)
```

## Discover supported attributes

[`listAttributes()`](https://huber-group-embl.github.io/remart/reference/listAttributes.md)
reports the attributes currently implemented by
*[remart](https://bioconductor.org/packages/3.23/remart)*:

``` r

listAttributes()
#>  [1] "chromosome_name"       "description"           "end_position"         
#>  [4] "ensembl_gene_id"       "ensembl_peptide_id"    "ensembl_transcript_id"
#>  [7] "external_gene_name"    "gene_biotype"          "hgnc_symbol"          
#> [10] "start_position"        "strand"                "transcript_biotype"   
#> [13] "version"
```

The supported filters for
[`getBM()`](https://huber-group-embl.github.io/remart/reference/getBM.md)
are currently limited to `ensembl_gene_id` and `ensembl_transcript_id`,
and only one filter can be used per call.

## Retrieve gene annotations

[`getBM()`](https://huber-group-embl.github.io/remart/reference/getBM.md)
accepts the familiar `attributes`, `filters`, and `values` arguments.
The following query retrieves basic annotations for two human Ensembl
genes. The connection to Ensembl is handled internally, so a `mart`
object is not required.

``` r

gene_ids <- c("ENSG00000157764", "ENSG00000004939")

gene_annotations <- getBM(
  attributes = c(
    "ensembl_gene_id",
    "external_gene_name",
    "chromosome_name",
    "start_position",
    "end_position"
  ),
  filters = "ensembl_gene_id",
  values = gene_ids
)

head(gene_annotations)
```

Attributes are returned in the order requested. Duplicate identifiers
are handled internally, while identifiers that Ensembl cannot find are
omitted with a warning.

## Retrieve transcript-level annotations

Transcript-level attributes can be requested using gene identifiers.
Because a gene can have multiple transcripts, this may return multiple
rows for one gene.

``` r

transcript_annotations <- getBM(
  attributes = c(
    "ensembl_gene_id",
    "ensembl_transcript_id",
    "ensembl_peptide_id",
    "transcript_biotype"
  ),
  filters = "ensembl_gene_id",
  values = "ENSG00000157764"
)

head(transcript_annotations)
```

Alternatively, transcript identifiers can be used as the filter when the
query is transcript-oriented:

``` r

getBM(
  attributes = c(
    "ensembl_transcript_id",
    "ensembl_gene_id",
    "ensembl_peptide_id"
  ),
  filters = "ensembl_transcript_id",
  values = "ENST00000357654"
)
```

## Use the `getGene()` compatibility wrapper

For workflows written around `biomaRt::getGene()`,
[`getGene()`](https://huber-group-embl.github.io/remart/reference/getGene.md)
provides a convenient gene-level interface:

``` r

getGene(
  id = c("ENSG00000157764", "ENSG00000004939"),
  type = "ensembl_gene_id"
)
```

The returned columns include `ensembl_gene_id`, `hgnc_symbol`, genomic
coordinates, strand, and description. Ensembl’s REST response does not
provide the `band` field used by
*[biomaRt](https://bioconductor.org/packages/3.23/biomaRt)*, so
*[remart](https://bioconductor.org/packages/3.23/remart)* returns `band`
as `NA` with a warning.

## Retrieve sequences

[`getSequence()`](https://huber-group-embl.github.io/remart/reference/getSequence.md)
retrieves sequences by Ensembl gene, transcript, or peptide identifier.

For example, a cDNA sequence can be retrieved for a transcript as
follows:

``` r

cdna <- getSequence(
  seqType = "cdna",
  type = "ensembl_transcript_id",
  id = "ENST00000357654"
)

summary(cdna)
```

Upstream and downstream bases can be requested for supported sequence
queries:

``` r

extended_cdna <- getSequence(
  seqType = "cdna",
  type = "ensembl_transcript_id",
  id = "ENST00000357654",
  upstream = 100,
  downstream = 100
)

summary(extended_cdna)
```

Coordinate-based requests using `chromosome`, `start`, and `end` are not
yet implemented.

## Find orthologues

[`getLDS()`](https://huber-group-embl.github.io/remart/reference/getLDS.md)
retains the familiar
*[biomaRt](https://bioconductor.org/packages/3.23/biomaRt)* name, but
its current implementation is specifically for orthology queries through
Ensembl’s homology endpoint. The target species is supplied with
`speciesL`; this replaces the linked `martL` connection used by
*[biomaRt](https://bioconductor.org/packages/3.23/biomaRt)*.

The following example searches for mouse orthologues of a human gene:

``` r

orthologues <- getLDS(
  attributes = c("ensembl_gene_id", "external_gene_name"),
  filters = "ensembl_gene_id",
  values = "ENSG00000157764",
  attributesL = c("ensembl_gene_id", "external_gene_name"),
  speciesL = "mouse"
)

orthologues
```

Only `ensembl_gene_id` is currently supported as the source filter.
Source and target attributes are gene-level attributes; transcript-level
linked queries are not yet supported.

## Migrating common *[biomaRt](https://bioconductor.org/packages/3.23/biomaRt)* code

A typical *[biomaRt](https://bioconductor.org/packages/3.23/biomaRt)*
workflow creates a connection before calling
[`getBM()`](https://huber-group-embl.github.io/remart/reference/getBM.md):

``` r

# A biomaRt workflow.
# This example is not actually run as the biomart service is unstable.
gene_ids <- c("ENSG00000157764", "ENSG00000004939")
attrs <- c(
  "ensembl_gene_id",
  "external_gene_name",
  "chromosome_name",
  "start_position",
  "end_position"
)
mart <- biomaRt::useEnsembl("ensembl", dataset = "hsapiens_gene_ensembl")
biomaRt::getBM(
  attributes = attrs,
  filters = "ensembl_gene_id",
  values = gene_ids,
  mart = mart
)
```

With *[remart](https://bioconductor.org/packages/3.23/remart)*, the
connection setup is removed and the query can usually be adapted
directly:

``` r

gene_ids <- c("ENSG00000157764", "ENSG00000004939")
attrs <- c(
  "ensembl_gene_id",
  "external_gene_name",
  "chromosome_name",
  "start_position",
  "end_position"
)
getBM(
  attributes = attrs,
  filters = "ensembl_gene_id",
  values = gene_ids
)
```

Several obsolete connection-related arguments are accepted through `...`
for source compatibility. Check
[`listAttributes()`](https://huber-group-embl.github.io/remart/reference/listAttributes.md)
and the function reference before migrating a workflow that uses less
common filters or attributes.

## Roadmap and future direction

We aim to implement additional filters and attributes, but we do not
have full visibility on how
*[biomaRt](https://bioconductor.org/packages/3.23/biomaRt)* is currently
used in workflows in production. If you have a specific use case that is
not currently supported, please open an issue on GitHub.

## Session information

``` r

utils::sessionInfo()
#> R version 4.6.1 (2026-06-24)
#> Platform: x86_64-pc-linux-gnu
#> Running under: Ubuntu 24.04.4 LTS
#> 
#> Matrix products: default
#> BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3 
#> LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.26.so;  LAPACK version 3.12.0
#> 
#> locale:
#>  [1] LC_CTYPE=C.UTF-8       LC_NUMERIC=C           LC_TIME=C.UTF-8       
#>  [4] LC_COLLATE=C.UTF-8     LC_MONETARY=C.UTF-8    LC_MESSAGES=C.UTF-8   
#>  [7] LC_PAPER=C.UTF-8       LC_NAME=C              LC_ADDRESS=C          
#> [10] LC_TELEPHONE=C         LC_MEASUREMENT=C.UTF-8 LC_IDENTIFICATION=C   
#> 
#> time zone: UTC
#> tzcode source: system (glibc)
#> 
#> attached base packages:
#> [1] stats     graphics  grDevices utils     datasets  methods   base     
#> 
#> other attached packages:
#> [1] remart_0.99.3    BiocStyle_2.40.0
#> 
#> loaded via a namespace (and not attached):
#>  [1] cli_3.6.6           knitr_1.51          rlang_1.3.0        
#>  [4] xfun_0.60           otel_0.2.0          textshaping_1.0.5  
#>  [7] jsonlite_2.0.0      htmltools_0.5.9     ragg_1.5.2         
#> [10] sass_0.4.10         rmarkdown_2.31      evaluate_1.0.5     
#> [13] jquerylib_0.1.4     fastmap_1.2.0       yaml_2.3.12        
#> [16] lifecycle_1.0.5     bookdown_0.47       BiocManager_1.30.27
#> [19] compiler_4.6.1      fs_2.1.0            systemfonts_1.3.2  
#> [22] digest_0.6.39       R6_2.6.1            curl_7.1.0         
#> [25] bslib_0.12.0        tools_4.6.1         pkgdown_2.2.1      
#> [28] cachem_1.1.0        desc_1.4.3
```
