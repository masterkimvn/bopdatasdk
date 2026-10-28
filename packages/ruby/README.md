# BOP Data SDK for Ruby

Read-only SDK for [BOP Data](https://data.bop.ink). After RubyGems publication: `gem install bop-data-sdk`.

```ruby
require 'bop_data'
client = BopData::Client.new
catalog = client.list_datasets
p client.get_dataset(catalog['datasets'][0]['canonicalId'])['data']
```

SDK MIT. Please credit source data as **BOP Data**, respecting original dataset terms.
