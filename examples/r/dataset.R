# Requires jsonlite. Reads the catalog and fetches the first dataset.
if (!requireNamespace("jsonlite", quietly = TRUE)) stop("Install the jsonlite package first")
base <- "https://data.bop.ink/api/v1/datasets"
catalog <- jsonlite::fromJSON(paste0(base, ".json"), simplifyVector = FALSE)
id <- catalog$datasets[[1]]$canonicalId
if (!grepl("^[A-Za-z0-9._-]{3,}$", id, perl = TRUE)) stop("Invalid canonical ID")
dataset <- jsonlite::fromJSON(paste0(base, "/", id, ".json"), simplifyVector = FALSE)
print(dataset$freshness)
print(dataset$provenance)
