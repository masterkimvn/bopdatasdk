# Rust client

This crate is under development and not published. It provides blocking catalog, dataset and raw CSV requests. Use `Client::default()` or configure `Client::new(base_url, timeout)`. Responses are `serde_json::Value` and retain unknown fields. The default response limit is 8 MB. Run `cargo test` to verify locally.
