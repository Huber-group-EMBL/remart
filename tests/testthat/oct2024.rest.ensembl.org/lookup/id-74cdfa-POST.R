structure(list(method = "POST", url = "https://oct2024.rest.ensembl.org/lookup/id", 
    status_code = 200L, headers = structure(list(vary = "Content-Type", 
        vary = "Origin", `content-type` = "application/json", 
        `strict-transport-security` = "max-age=31536000; includeSubDomains; preload", 
        date = "Wed, 18 Nov 2026 13:54:42 GMT", `x-ratelimit-limit` = "55000", 
        `x-ratelimit-reset` = "318", `x-runtime` = "1.007167", 
        `x-ratelimit-period` = "3600", `x-ratelimit-remaining` = "54999", 
        `content-length` = "476"), class = "httr2_headers"), 
    body = charToRaw("{\"ENSG00000157764\":{\"db_type\":\"core\",\"id\":\"ENSG00000157764\",\"logic_name\":\"ensembl_havana_gene_homo_sapiens\",\"description\":\"B-Raf proto-oncogene, serine/threonine kinase [Source:HGNC Symbol;Acc:HGNC:1097]\",\"biotype\":\"protein_coding\",\"display_name\":\"BRAF\",\"start\":140719327,\"end\":140924929,\"assembly_name\":\"GRCh38\",\"seq_region_name\":\"7\",\"species\":\"homo_sapiens\",\"version\":14,\"canonical_transcript\":\"ENST00000646891.2\",\"source\":\"ensembl_havana\",\"object_type\":\"Gene\",\"strand\":-1}}"), 
    timing = c(redirect = 0, namelookup = 0.026406, connect = 0.042835, 
    pretransfer = 0.082544, starttransfer = 1.119622, total = 1.119634
    ), cache = new.env(parent = emptyenv())), class = "httr2_response")
