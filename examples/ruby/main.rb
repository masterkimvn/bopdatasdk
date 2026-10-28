require 'bop_data'
client = BopData::Client.new
catalog = client.list_datasets
dataset = client.get_dataset(catalog.fetch('datasets').first.fetch('canonicalId'))
puts JSON.pretty_generate({freshness: dataset['freshness'], provenance: dataset['provenance']})
