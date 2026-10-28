# BOP Data SDK

Lightweight read-only clients for public datasets from [BOP Data](https://data.bop.ink). Discover datasets through the [catalog](https://data.bop.ink/api/v1/datasets.json) and inspect the [API specification](https://data.bop.ink/openapi.json).

JavaScript, Python, PHP, Go, Java, Ruby and Rust clients are available in this repository as development source. Packages have not been released; registry names and the source license are pending approval. The examples below run from a checkout. Requirements: Node 18+, Python 3.9+, PHP 8.1+ with cURL, Go 1.21+, Java 11+, Ruby 3.0+, or a current stable Rust toolchain.

Choose a canonical ID from the catalog. For example, `vn.vien-thong-ha-tang-so.ten-mien-ip-asn.danh-sach-asn-viet-nam` identifies [this dataset](https://data.bop.ink/vien-thong-ha-tang-so/ten-mien-ip-asn/danh-sach-asn-viet-nam); its human URL is provided by `links.html`.

```js
import { BopDataClient } from './packages/javascript/index.js';
const client = new BopDataClient();
const catalog = await client.listDatasets();
const dataset = await client.getDataset(catalog.datasets[0].canonicalId);
console.log(dataset.data, dataset.freshness, dataset.provenance);
```

```python
from bop_data import BopDataClient
client = BopDataClient()
catalog = client.list_datasets()
dataset = client.get_dataset(catalog['datasets'][0]['canonicalId'])
print(dataset['freshness'], dataset['provenance'])
```

Run Python from the checkout with `PYTHONPATH=packages/python/src python3 examples/python/main.py`. PHP and Go examples are in [examples](docs/examples.md). Each client also returns the catalog and raw CSV; CSV may start with a UTF-8 BOM. The clients perform GET requests and do not cache or automatically retry. The default timeout is 10 seconds. Errors are raised for invalid IDs, failed requests, invalid JSON and incompatible response specifications.

Cross-origin browser access is not currently promised: the API responses checked did not include an `Access-Control-Allow-Origin` header. Use a server runtime unless the provider's CORS policy permits your origin.

Dataset freshness and provenance are provided by the API. Check each dataset's license and its sources before use or redistribution; the SDK's source license does not grant rights to dataset contents. See [data rights](docs/data-rights.md), [API](docs/api.md), [Vietnamese quickstart](docs/vi/quickstart.md), [contributing](CONTRIBUTING.md), and [security](SECURITY.md).
