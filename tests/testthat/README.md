# Test fixtures

The JSON files in this directory are recorded HTTP responses from the
[Ensembl REST API](https://rest.ensembl.org/). They are replayed by
[httptest2](https://enpiar.com/httptest2/) through `use_mock_api()` in
[`setup.R`](setup.R), so the test suite runs offline.

## Terms

These files contain Ensembl data and are subject to Ensembl terms of use. 
Ensembl states that it "imposes no restrictions on access to, or
use of, the data"
([Ensembl disclaimer](https://www.ensembl.org/info/about/legal/disclaimer.html)),
and asks that users [cite Ensembl in publications](https://www.ensembl.org/info/about/publications.html).
Please refer to the [cite Ensembl page](https://www.ensembl.org/info/about/publications.html)
to find the appropriate citation for a given Ensembl release.
