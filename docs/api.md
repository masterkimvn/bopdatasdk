# API

The clients call `GET /api/v1/datasets.json`, `GET /api/v1/datasets/{canonicalId}.json` and `GET /api/v1/datasets/{canonicalId}.csv`. Catalog and dataset responses must have `spec` values `bop.catalog/1` and `bop.dataset/1` respectively. Additional fields are preserved. Go returns JSON values as `json.RawMessage`; PHP and Python return associative structures, and JavaScript returns objects.

IDs must contain at least three ASCII letters, digits, dots, underscores or hyphens. A custom base URL is intended for trusted deployments and tests; do not derive it from untrusted input. No credentials are required. HTTP errors and malformed or incompatible JSON are reported to callers. CSV is returned as UTF-8 text in JavaScript and Python, and bytes in Go and PHP.

Redirects are rejected. Set a trusted base URL directly when using another deployment. The clients read each response into memory.
