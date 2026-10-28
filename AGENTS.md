# AGENTS.md — BOP Data SDK

Public guidance for AI coding agents working **with or inside** the [BOP Data SDK repository](https://github.com/masterkimvn/bopdatasdk). This file is for any developer or AI assistant using the project; it is not an internal project-management prompt.

## What this project is

- **[BOP Data](https://data.bop.ink)** is the public, non-profit, ad-free **structured dataset source**.
- **BOP Data SDK** is a set of lightweight **read-only API connectors** for using those datasets in websites, services, mobile apps, software, and AI applications.
- **Do not confuse the two.** This repository neither owns nor validates the underlying data, and it does not manage the BOP Data production backend.
- **Creator:** Phạm Hoàng Đức (Master Kim) — [about.bop.ink](https://about.bop.ink).
- The goal is simple: **Find → See → Done**. Help the user retrieve actual data with as little integration work as possible.

## When a user asks you to integrate BOP Data

1. **Identify the target runtime:** Node.js, browser, Python, PHP, Go, Java, .NET, Rust, Ruby, Kotlin/Android, Swift/iOS, Dart/Flutter, or another environment.
2. **Select the appropriate existing client** in [`packages/`](packages/) and read [docs/clients.md](docs/clients.md) for its exact API and local installation instructions. Do not invent method names or public registry package names.
3. **Explore the catalog** at `https://data.bop.ink/api/v1/datasets.json` to discover a real `canonicalId` for the user's use case. Do not assume example IDs will always exist or meet the user's needs.
4. **Retrieve actual data** using the SDK's catalog/JSON/CSV methods. Return it to the caller or display a useful value in the user's application.
5. **Keep the integration minimal.** Prefer a small function or component that calls the SDK over a new service, database, synchronization pipeline, dashboard, or data-validation engine.
6. **Handle basic failures** gracefully (network errors, HTTP status, timeouts, missing IDs, invalid responses). Show the user what happened; do not fabricate fallback dataset values.
7. **Credit the source:** include a user-visible `BOP Data` acknowledgement when showing BOP Data datasets. A link is welcome but not required for this project-level acknowledgement. See dataset-specific rights separately.

If the user only wants a single dataset request and their environment already has HTTP/JSON support, a direct request to the public API may be simpler than adding an SDK dependency.

## API contract

Default base URL: `https://data.bop.ink` (public, read-only; no API key required).

| Action | HTTP request | Expected response |
| --- | --- | --- |
| Discover datasets | `GET /api/v1/datasets.json` | JSON catalog, `spec: "bop.catalog/1"` |
| Retrieve a dataset | `GET /api/v1/datasets/{canonicalId}.json` | JSON dataset, `spec: "bop.dataset/1"` |
| Retrieve CSV | `GET /api/v1/datasets/{canonicalId}.csv` | CSV bytes / text |

Canonical IDs come from the live catalog; they are **not** human-readable page URLs. The API specification is at [data.bop.ink/openapi.json](https://data.bop.ink/openapi.json). Consult [docs/api.md](docs/api.md) for contract details.

The dataset response may include `identity`, `data`, `freshness`, `provenance`, and `links`. **Preserve the original response** and unknown fields where possible. Do not invent columns, modify dataset values, or independently adjudicate the factual accuracy of the source data.

### JavaScript / Node.js from the checkout

```js
import { BopDataClient } from './packages/javascript/index.js';

const client = new BopDataClient();
const catalog = await client.listDatasets();
const id = catalog.datasets[0].canonicalId;
const dataset = await client.getDataset(id);
console.log(dataset.data);
```

### Python from the checkout

```python
from bop_data import BopDataClient

client = BopDataClient()
catalog = client.list_datasets()
id = catalog["datasets"][0]["canonicalId"]
dataset = client.get_dataset(id)
print(dataset["data"])
```

Python in this checkout requires `PYTHONPATH=packages/python/src` unless the local package has been installed. For other languages and CSV return types, use [docs/clients.md](docs/clients.md).

## Platform-specific behavior

- **Browser-side React/Vue/plain JS:** cross-origin requests work only when BOP Data's API allows the requesting origin through CORS. Do not promise direct browser access or attempt to bypass browser security. A server-side integration is an option if the user's existing architecture supports it.
- **Next.js:** consider an existing server-side route/component for the API request; avoid creating a separate backend solely to use BOP Data.
- **Android / iOS / Flutter:** use the relevant native SDK or example. Avoid blocking the main UI thread with networking. Device/simulator compatibility is not claimed where it has not been tested.
- **AI/agent systems:** let the application call the SDK/API in its own supported runtime. Do not imply this repository automatically supplies an MCP server or any unimplemented agent protocol.
- **CSV:** treat the response as source data, preserving UTF-8 and handling a possible BOM according to the language/runtime.

## Repository map

| Location | Purpose |
| --- | --- |
| [`packages/`](packages/) | 11 language clients: JavaScript/TypeScript, Python, PHP, Go, Java, .NET, Rust, Ruby, Kotlin, Swift, Dart |
| [`examples/`](examples/) | Consumer examples for languages, web frameworks, and mobile environments |
| [`docs/clients.md`](docs/clients.md) | Exact methods, requirements, and local installation |
| [`docs/examples.md`](docs/examples.md) | How to run the examples |
| [`docs/api.md`](docs/api.md) | API contract |
| [`docs/data-rights.md`](docs/data-rights.md) | Source-data rights and freshness |
| [`tests/`](tests/) | Test fixtures and consumer checks |
| [`.github/workflows/ci.yml`](.github/workflows/ci.yml) | CI jobs per runtime |

## If you are editing this SDK repository

- Keep changes **small and read-only**. The product is a connector, not a data-processing framework.
- Follow existing naming and error-handling conventions in the client you change. Do not break published method semantics, output shape, or losslessly carried API fields.
- Keep tests focused on **transport, decoding, and caller usability**; use synthetic fixtures for automated testing. A live API smoke request can demonstrate that real data reaches a consumer, but it is not an audit of the underlying facts.
- Run the relevant language tests and examples documented in the repository. Report any platform/toolchain tests you could not run instead of claiming success.
- Never commit credentials, secrets, local environment files, downloaded datasets with uncertain reuse rights, generated build artifacts, or internal-only workspace files.
- **Do not publish packages, tag releases, or change production BOP Data** without explicit authorization.
- The clients currently exist as repository source; public registry releases and the SDK source license are **pending**. Do not instruct users to install unverified registry names or assume an open-source license has already been granted.

## Attribution and rights

When creating an example or integrating a dataset, please acknowledge **BOP Data** as the data source. The text **`BOP Data`** is sufficient for the project's requested recognition; linking to [data.bop.ink](https://data.bop.ink) is welcome but optional for this acknowledgement.

This is not a substitute for legal permissions. A dataset or its original source may specify additional obligations in `provenance` or linked terms. The SDK's licensing status and the dataset's usage rights are separate.

## Finish well

For an integration task, deliver **working caller-side code** and show how to run it; demonstrate a catalog lookup or a real dataset request when network access is available. Prefer a successful data retrieval over an elaborate architecture or repeated data-source audits.

For a contribution task, explain which files changed and which relevant checks actually ran. Keep documentation honest about platform support and release status.
