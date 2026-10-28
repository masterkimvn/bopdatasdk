import { BopDataClient } from '../../packages/javascript/index.js';
const client = new BopDataClient();
const catalog = await client.listDatasets();
const dataset = await client.getDataset(catalog.datasets[0].canonicalId);
console.log(dataset.freshness, dataset.provenance);
