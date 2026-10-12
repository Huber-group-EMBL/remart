# Comparison between remart and biomaRt

While we tried as much as possible to reproduce the biomaRt interface,
there are some differences between the two packages, and limitations
that we won’t be able to overcome.

## Interface

### New `species` / `speciesL` argument

In biomaRt, the `mart` argument was used to specify the database to
connect to, this usually contained some information about the species of
interest. This enabled for example the conversion of gene symbols to
Ensembl gene IDs (since multiple species can have the same gene symbol).
In remart, the `mart` argument is no longer required, and the species of
interest is specified via the new `species` argument in
[`getBM()`](https://huber-group-embl.github.io/remart/reference/getBM.md)
and `speciesL` argument in
[`getLDS()`](https://huber-group-embl.github.io/remart/reference/getLDS.md).

### New `version` argument

In biomaRt, the Ensembl version to query could be specified with the
`version` argument (or directly in the `host` argument) in
`useEnsembl()`. In remart, the `version` argument is now available in
all functions that query Ensembl, and it is used to specify the Ensembl
release to query. If not specified, the latest release will be used.
