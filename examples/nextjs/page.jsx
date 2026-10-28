import { BopDataClient } from 'bop-data-sdk-local';

// A server component: use an ID from the catalog.
export default async function Page() {
  try {
    const client = new BopDataClient();
    const catalog = await client.listDatasets();
    const first = catalog.datasets[0];
    if (!first) return <p>No datasets available.</p>;
    const dataset = await client.getDataset(first.canonicalId);
    return <pre>{JSON.stringify({ data: dataset.data, freshness: dataset.freshness, provenance: dataset.provenance }, null, 2)}</pre>;
  } catch {
    return <p>Unable to load data at this time.</p>;
  }
}
