# Ruby client

The Ruby package is under development and is not published. Build locally with `gem build bop_data_sdk.gemspec`, then install the resulting gem into a local Ruby environment. Require `bop_data` and instantiate `BopData::Client`; see `examples/ruby/main.rb` in the repository. `list_datasets`, `get_dataset(id)`, and `get_dataset_csv(id)` perform read-only requests. The last method returns UTF-8 CSV including any BOM. Errors use `BopData::Error` with `kind` and optional HTTP `status`.
