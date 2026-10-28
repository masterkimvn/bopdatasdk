from bop_data import BopDataClient
client = BopDataClient()
catalog = client.list_datasets()
dataset = client.get_dataset(catalog['datasets'][0]['canonicalId'])
print(dataset['freshness'], dataset['provenance'])
