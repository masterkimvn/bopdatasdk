# Using the clients

All clients call the public BOP Data API. Discover a `canonicalId` with the catalog, then request its JSON dataset or CSV. The dataset includes `data`, `freshness`, `provenance` and `links` when supplied by the API. JSON is returned without flattening the fields; CSV is returned as text or bytes, depending on the language. Check the data's own terms before redistribution.

The repository has a [v1.0.0 GitHub source release](https://github.com/masterkimvn/bopdatasdk/releases/tag/v1.0.0). This is a versioned snapshot of all clients, **not** a publication of individual packages to language registries. Independent package names and versions are now prepared for registry distribution, but actual registry publication still requires verification.

The packages below are development source in this repository, not published registry releases. Names are candidates until registry ownership is confirmed. Run commands from the repository root unless stated otherwise. A custom base URL is for trusted deployments and tests. No API key is required.

| Language | Catalog | Dataset JSON | CSV |
| --- | --- | --- | --- |
| JavaScript / TypeScript | `listDatasets()` | `getDataset(id)` | `getDatasetCsv(id)` (string) |
| Python | `list_datasets()` | `get_dataset(id)` | `get_dataset_csv(id)` (string) |
| PHP | `listDatasets()` | `getDataset($id)` | `getDatasetCsv($id)` (string) |
| Go | `ListDatasets(ctx)` | `GetDataset(ctx, id)` | `GetDatasetCSV(ctx, id)` (bytes) |
| Java | `listDatasets()` | `getDataset(id)` | `getDatasetCsv(id)` (bytes) |
| C# / .NET | `ListDatasetsAsync()` | `GetDatasetAsync(id)` | `GetDatasetCsvAsync(id)` (bytes) |
| Rust | `list_datasets()` | `get_dataset(id)` | `get_dataset_csv(id)` (bytes) |
| Ruby | `list_datasets` | `get_dataset(id)` | `get_dataset_csv(id)` (string) |
| Kotlin / JVM | `listDatasets()` | `getDataset(id)` | `getDatasetCsv(id)` (bytes) |
| Swift | `listDatasets()` | `getDataset(id)` | `getDatasetCSV(id)` (`Data`) |
| Dart | `listDatasets()` | `getDataset(id)` | `getDatasetCsv(id)` (`Uint8List`) |

## Run from a checkout

- **JavaScript:** `node examples/javascript-node/main.js`. For a separate Node or framework project, run `npm pack` in `packages/javascript`, then run `npm install /path/to/the/generated.tgz` in the consumer. Import `BopDataClient` from `bop-data-sdk`.
- **Python:** `PYTHONPATH=packages/python/src python3 examples/python/main.py`. To install locally, run `python3 -m pip install ./packages/python` in your virtual environment and import `BopDataClient` from `bop_data`.
- **PHP:** run `composer install --working-dir=packages/php` then `php examples/php/composer.php`. For a separate consumer, configure a Composer path repository pointing to `packages/php` and set `options.versions` to `{"bopink/data-sdk":"1.0.0"}` for that path repository and require `bopink/data-sdk` at `^1.0`; see [Composer path repositories](https://getcomposer.org/doc/05-repositories.md#path).
- **Go:** `cd packages/go && go run ./examples`. A local consumer can require `github.com/masterkimvn/bopdatasdk/packages/go` and use a `replace` directive pointing to the checkout's `packages/go` directory. No Go module version tag has been released.
- **Java:** run `mvn install` in `packages/java`. A local Maven consumer can depend on `ink.bop:data-sdk:1.0.0` and use `ink.bop.data.Client`. See `examples/java/Main.java`.
- **C# / .NET:** `dotnet run --project examples/dotnet/Demo.csproj`. To use a package, run `dotnet pack packages/dotnet/BopData/BopData.csproj -o /path/to/local-feed`, then add `BopData.SDK` version `1.0.0` from that local feed to the consumer. Import `BopData`.
- **Rust:** `cargo run --manifest-path packages/rust/Cargo.toml --example dataset`. In a consumer, add `bop-data-sdk = { path = "/path/to/checkout/packages/rust" }` to dependencies and use `bop_data_sdk::Client`.
- **Ruby:** run `gem build bop_data_sdk.gemspec` in `packages/ruby`, then install the resulting gem into your Ruby environment with `gem install --local /path/to/bop-data-sdk-1.0.0.gem`. Run `ruby examples/ruby/main.rb` from the root.
- **Kotlin:** run `mvn install` in `packages/kotlin`; the local Maven artifact is `ink.bop:data-kotlin:1.0.0`. JVM consumers must supply `org.json`; Android provides that API. Use `ink.bop.data.BopDataClient` on a background thread. See `examples/kotlin/Main.kt` and [Android example](../examples/android/GUIDE.md).
- **Swift:** add `packages/swift` as a local package in Xcode and `import BopData`. See the [SwiftUI example](../examples/swift/GUIDE.md).
- **Dart:** `cd packages/dart && dart pub get && dart run example/main.dart`. In another Dart or Flutter project use a `path` dependency pointing to `packages/dart` and import `package:bop_data_sdk/bop_data.dart`.

See [examples](examples.md) for the Flutter application, framework integrations, and standalone C, C++, R, PowerShell and shell scripts. Direct browser calls require the API to allow the application's origin through CORS; the API did not return the required header in the last check. Mobile native networking is separate from browser CORS. Android and iOS native examples have not been built or run on a device or simulator.
