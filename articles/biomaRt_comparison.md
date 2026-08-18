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

## Limitations

Because *[remart](https://bioconductor.org/packages/3.23/remart)*
queries Ensembl at execution time, a result is determined by the current
Ensembl service and annotation release rather than by a bundled
snapshot. For reproducible analyses, record the date of access, the
Ensembl identifiers queried, the requested attributes, and the version
of *[remart](https://bioconductor.org/packages/3.23/remart)*.

Additionally, Ensembl is the supported backend; arbitrary BioMart
databases are not.
