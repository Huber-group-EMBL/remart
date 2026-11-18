# httptest2 fixture for HEAD request
structure(
  list(
    method = "HEAD",
    url = "https://may2025.rest.ensembl.org/",
    status_code = 200L,
    headers = structure(
      list(
        date = "Wed, 18 Nov 2026 13:50:00 GMT",
        `content-type` = "text/html; charset=utf-8",
        `content-length` = "0",
        `x-ensembl-rest-version` = "15.10"
      ),
      class = "httr2_headers"
    ),
    body = raw(0),
    timing = c(
      redirect = 0.10349,
      namelookup = 0.037653,
      connect = 5.069123,
      pretransfer = 5.13514,
      starttransfer = 5.180305,
      total = 5.18039
    ),
    cache = new.env(parent = emptyenv())
  ),
  class = "httr2_response"
)
