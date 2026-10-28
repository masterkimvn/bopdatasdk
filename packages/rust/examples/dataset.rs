use bop_data_sdk_local::Client;
fn main() -> Result<(), Box<dyn std::error::Error>> {
    let client = Client::default();
    let catalog = client.list_datasets()?;
    let id = catalog["datasets"][0]["canonicalId"]
        .as_str()
        .ok_or("no dataset")?;
    let dataset = client.get_dataset(id)?;
    println!(
        "freshness: {}\nprovenance: {}",
        dataset["freshness"], dataset["provenance"]
    );
    Ok(())
}
