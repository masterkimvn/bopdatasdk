# BOP Data SDK for Python

Lightweight read-only SDK for [BOP Data](https://data.bop.ink). Once published on PyPI: `pip install bop-data-sdk`.

```python
from bop_data import BopDataClient
client = BopDataClient()
catalog = client.list_datasets()
dataset = client.get_dataset(catalog["datasets"][0]["canonicalId"])
print(dataset["data"])
```

Please credit data as **BOP Data**. Individual dataset rights are independent from the MIT license of SDK code.
