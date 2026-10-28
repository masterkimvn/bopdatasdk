# Examples

From the repository root:

- JavaScript: `node examples/javascript-node/main.js`
- Python: `PYTHONPATH=packages/python/src python3 examples/python/main.py`
- PHP: `php examples/php/vanilla.php` (requires cURL); for the package example, run `composer install --working-dir=packages/php` then `php examples/php/composer.php`
- Go: `cd packages/go && go run ./examples`

Each example reads the catalog and then fetches its first dataset. Network access to data.bop.ink is required.

Additional source examples:

- Ruby: build and install `packages/ruby/bop_data_sdk.gemspec`, then run `ruby examples/ruby/main.rb` in that environment.
- Shell: `bash examples/shell/dataset.sh` retrieves the catalog; pass a canonical ID to retrieve JSON. Requires curl.
- C: `cc examples/c/dataset.c -lcurl -o dataset-c` then `./dataset-c CANONICAL_ID json` (or `csv`). Requires libcurl headers and library.
- C++: `c++ -std=c++17 examples/cpp/dataset.cpp -lcurl -o dataset-cpp` then `./dataset-cpp CANONICAL_ID json` (or `csv`). Requires libcurl headers and library.

- Java: see `examples/java/Main.java` and `packages/java/README.md`; the client requires Jackson on the classpath.

- Rust: `cargo run --manifest-path packages/rust/Cargo.toml --example dataset`.
- R: install `jsonlite`, then run `Rscript examples/r/dataset.R`.

- .NET: `dotnet run --project examples/dotnet/Demo.csproj` requires .NET 8.

- Dart: `cd packages/dart && dart pub get && dart run example/main.dart`.

Framework integration snippets are available for [React](../examples/react/README.md), [Vue](../examples/vue/README.md), [Next.js](../examples/nextjs/README.md) and [React Native](../examples/react-native/README.md). Install the local JavaScript package into your application first. The browser examples depend on API CORS policy; React Native device compatibility remains unverified.
