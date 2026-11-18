structure(list(method = "POST", url = "https://oct2024.rest.ensembl.org/lookup/id", 
    status_code = 200L, headers = structure(list(vary = "Content-Type", 
        vary = "Origin", `content-type` = "application/json", 
        `strict-transport-security` = "max-age=31536000; includeSubDomains; preload", 
        date = "Wed, 18 Nov 2026 13:54:48 GMT", `x-ratelimit-limit` = "55000", 
        `x-ratelimit-reset` = "312", `x-runtime` = "1.425293", 
        `x-ratelimit-period` = "3600", `x-ratelimit-remaining` = "54997", 
        `content-length` = "460"), class = "httr2_headers"), 
    body = charToRaw("{\"ENSMUSG00000002413\":{\"description\":\"Braf transforming gene [Source:MGI Symbol;Acc:MGI:88190]\",\"display_name\":\"Braf\",\"biotype\":\"protein_coding\",\"start\":39580171,\"db_type\":\"core\",\"id\":\"ENSMUSG00000002413\",\"logic_name\":\"ensembl_havana_gene_mus_musculus\",\"strand\":-1,\"assembly_name\":\"GRCm39\",\"end\":39702397,\"seq_region_name\":\"6\",\"version\":16,\"species\":\"mus_musculus\",\"canonical_transcript\":\"ENSMUST00000002487.15\",\"source\":\"ensembl_havana\",\"object_type\":\"Gene\"}}"), 
    timing = c(redirect = 0, namelookup = 2.8e-05, connect = 0, 
    pretransfer = 0.000141, starttransfer = 1.45343, total = 1.453466
    ), cache = new.env(parent = emptyenv())), class = "httr2_response")
