# BOP Data SDK for Rust

Read-only client for [BOP Data](https://data.bop.ink). After crates.io publication: `cargo add bop-data-sdk`.

```rust
use bop_data_sdk::Client;
let client = Client::default();
let catalog = client.list_datasets()?;
let id = catalog["datasets"][0]["canonicalId"].as_str().unwrap();
println!("{}", client.get_dataset(id)?["data"]);
```

MIT software license; dataset terms separate. Please credit source as **BOP Data**.
