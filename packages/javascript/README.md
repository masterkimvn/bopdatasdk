# BOP Data SDK for JavaScript / TypeScript

Read-only API client for [BOP Data](https://data.bop.ink), the non-profit, ad-free public structured dataset source.

Once published on npm: `npm install bop-data-sdk`.

```js
import { BopDataClient } from 'bop-data-sdk';
const client = new BopDataClient();
const catalog = await client.listDatasets();
const dataset = await client.getDataset(catalog.datasets[0].canonicalId);
console.log(dataset.data);
```

Direct browser use depends on the API's CORS policy. Prefer Node.js for server integrations. Please credit source datasets as **BOP Data**; dataset rights are separate from the SDK MIT license.
