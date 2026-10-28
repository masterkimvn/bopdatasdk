<p align="center">
  <a href="https://data.bop.ink">
    <img src="https://s3.cloudfly.vn/storagebopink/asset/bop-logo-horizontal-bop.png" alt="BOP — the ecosystem behind BOP Data" width="190">
  </a>
</p>

<h1 align="center">BOP Data SDK</h1>

<p align="center">
  <strong>Public structured datasets, ready for your website, app, software, or AI.</strong><br>
  Lightweight API clients for developers working with <a href="https://data.bop.ink"><strong>BOP Data</strong></a>.
</p>

<p align="center">
  <a href="https://data.bop.ink">Explore BOP Data</a> ·
  <a href="https://data.bop.ink/api/v1/datasets.json">Browse dataset catalog</a> ·
  <a href="#quick-start">Quick start</a> ·
  <a href="#supported-languages">SDKs</a> ·
  <a href="AGENTS.md">AI agent guide</a>
</p>

<p align="center">
  <a href="https://github.com/masterkimvn/bopdatasdk/actions/workflows/ci.yml"><img src="https://github.com/masterkimvn/bopdatasdk/actions/workflows/ci.yml/badge.svg" alt="GitHub Actions CI"></a>
</p>

**GitHub source release:** [v1.0.0](https://github.com/masterkimvn/bopdatasdk/releases/tag/v1.0.0) · [Changelog](CHANGELOG.md) · [Release notes](docs/releases/v1.0.0.md)

> **Version scope:** v1.0.0 is the GitHub **source repository** release. The 11 language packages have been prepared for distribution, but **registry availability is not yet confirmed**. SDK code is MIT licensed; dataset rights are separate. See [release and licensing details](docs/releasing.md).

## What is BOP Data?

**[BOP Data](https://data.bop.ink)** is a **non-profit, ad-free public structured data initiative** within the [BOP ecosystem](https://bop.ink). It makes structured datasets accessible to people, websites, software, mobile applications, and AI systems.

Discover datasets in its public catalog and retrieve them through a documented API. BOP Data is **the data source**; **BOP Data SDK is the connection layer** that helps developers use that source in their own projects.

- **Publicly accessible:** explore the [dataset catalog](https://data.bop.ink/api/v1/datasets.json) without an API key.
- **Structured responses:** retrieve dataset information as JSON or CSV.
- **Source context:** responses may include `freshness`, `provenance`, and links supplied by BOP Data.
- **Built to be used:** a small connector, not another database, data platform, or validation service.

> **The goal:** find a dataset → connect → use the data. No unnecessary integration work.

## Quick start

### 1. Explore the live API (no SDK required)

```bash
curl -fsS https://data.bop.ink/api/v1/datasets.json
```

Each catalog item provides a `canonicalId`. Use that identifier to fetch a dataset:

```text
GET https://data.bop.ink/api/v1/datasets/{canonicalId}.json
GET https://data.bop.ink/api/v1/datasets/{canonicalId}.csv
```

See the [OpenAPI specification](https://data.bop.ink/openapi.json) and [API notes](docs/api.md).

### 2. Use a client from this repository

Clone the source:

```bash
git clone https://github.com/masterkimvn/bopdatasdk.git
cd bopdatasdk
```

**JavaScript / Node.js** (Node 18+):

```js
import { BopDataClient } from './packages/javascript/index.js';

const client = new BopDataClient();
const catalog = await client.listDatasets();
const firstId = catalog.datasets[0].canonicalId;
const dataset = await client.getDataset(firstId);

console.log(dataset.data);       // Dataset content
console.log(dataset.freshness);  // Metadata supplied by BOP Data
```

Run the included working example with `node examples/javascript-node/main.js`.

**Python** (from this checkout):

```python
from bop_data import BopDataClient

client = BopDataClient()
catalog = client.list_datasets()
dataset = client.get_dataset(catalog["datasets"][0]["canonicalId"])
print(dataset["data"])
```

Run the example with:

```bash
PYTHONPATH=packages/python/src python3 examples/python/main.py
```

These examples make real requests to `data.bop.ink` and require a network connection. For installation from source, dependencies, and language-specific usage, read **[Using the clients](docs/clients.md)**.

> **Package status:** package manifests are being prepared for external registries. Do not assume any package is published until verified; registry publication still requires account setup and verification. Do not assume the example package names are installable from npm, PyPI, NuGet, Maven Central, or other registries.

## Supported languages

The repository contains client source code for **11 language families**:

| Language / ecosystem | Source | Usage |
| --- | --- | --- |
| JavaScript / TypeScript (Node.js) | [JavaScript](packages/javascript) | `listDatasets()` · `getDataset(id)` · `getDatasetCsv(id)` |
| Python | [Python](packages/python) | `list_datasets()` · `get_dataset(id)` · `get_dataset_csv(id)` |
| PHP | [PHP](packages/php) | `listDatasets()` · `getDataset(id)` · `getDatasetCsv(id)` |
| Go | [Go](packages/go) | `ListDatasets(ctx)` · `GetDataset(ctx, id)` · `GetDatasetCSV(ctx, id)` |
| Java | [Java](packages/java) | Catalog · JSON · CSV |
| C# / .NET | [.NET](packages/dotnet) | Catalog · JSON · CSV |
| Rust | [Rust](packages/rust) | Catalog · JSON · CSV |
| Ruby | [Ruby](packages/ruby) | Catalog · JSON · CSV |
| Kotlin (JVM / Android) | [Kotlin](packages/kotlin) | Catalog · JSON · CSV |
| Swift (Apple platforms) | [Swift](packages/swift) | Catalog · JSON · CSV |
| Dart (including Flutter) | [Dart](packages/dart) | Catalog · JSON · CSV |

For exact method names, local package installation, and requirements across languages, see **[docs/clients.md](docs/clients.md)**.

### Websites, mobile apps, and more

You can also explore runnable or integration-oriented examples:

- **Web frameworks:** [React](examples/react/README.md), [Vue](examples/vue/README.md), [Next.js](examples/nextjs/README.md).
- **Mobile:** [Flutter](examples/flutter/README.md), [Android](examples/android/GUIDE.md), [SwiftUI / iOS](examples/swift/GUIDE.md), [React Native](examples/react-native/README.md).
- **Other environments:** [C](examples/c), [C++](examples/cpp), [R](examples/r), [PowerShell](examples/powershell), [Shell](examples/shell).

See the [examples guide](docs/examples.md) for commands and requirements. Android/iOS device or simulator execution and React Native device compatibility have not been verified as part of the repository handoff.

## How the SDK works

```text
Your application
       │
       ▼
BOP Data SDK  ── HTTP GET ──▶  data.bop.ink
       │                             │
       ◀──── JSON / CSV response ────┘
       │
       ▼
Use the data in your UI, service, tool, or AI workflow
```

The SDK is deliberately small. It **does not** collect datasets, check whether their numbers are correct, mirror the dataset catalog, run a database, or modify data on the server. The source and its content remain the responsibility of BOP Data and the original data providers.

**Browser note:** direct requests from a website running in a browser depend on BOP Data's CORS policy. Cross-origin browser access is not guaranteed. Server-side code and native mobile networking are not subject to browser CORS in the same way. See [client notes](docs/clients.md).

## Credit BOP Data

If your project uses datasets provided by BOP Data, **please credit the data source as “BOP Data.”** This simple visible acknowledgement is the minimum recognition requested by the project. A link to [data.bop.ink](https://data.bop.ink) is appreciated but is **not necessary for that acknowledgement**.

For example: **Data source: BOP Data**

This acknowledgement request is distinct from legal licensing obligations. Individual datasets and their original sources may carry their own attribution, use, or redistribution requirements. Check `provenance` and [data rights](docs/data-rights.md) before redistribution. The SDK source license and dataset rights are separate.

## About the project

**BOP Data** is a public-facing, non-profit and ad-free structured dataset initiative. **BOP Data SDK** exists to help developers connect to it—not to replace or commercialize the data source.

**Created by:** **Phạm Hoàng Đức (Master Kim)** · [Official creator profile](https://about.bop.ink)

**Official links:** [BOP Data](https://data.bop.ink) · [BOP](https://bop.ink) · [OpenAPI](https://data.bop.ink/openapi.json) · [Creator](https://about.bop.ink)

## Documentation and contributing

- [Using the 11 clients](docs/clients.md) · [API](docs/api.md) · [Examples](docs/examples.md)
- [AI coding agents: AGENTS.md](AGENTS.md) — instructions for integrating BOP Data into another project or contributing here.
- [Data rights and freshness](docs/data-rights.md) · [Release status](docs/releasing.md)
- [Contributing](CONTRIBUTING.md) · [Security](SECURITY.md)

**Find → See → Done.** Get the data into your project, then get back to building.

## Registry package distribution

Each language SDK has an independent distribution identity and packaging process. **Preparation is not publication**: see [registry checklist](docs/registry-status.md) for actual availability and ownership setup. SDK software is [MIT licensed](LICENSE), separate from dataset rights; see [license scope](docs/license-scope.md).
