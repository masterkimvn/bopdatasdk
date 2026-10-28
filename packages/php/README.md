# BOP Data SDK for PHP

Read-only client for [BOP Data](https://data.bop.ink). After Packagist registration: `composer require bopink/data-sdk`.

```php
<?php
require __DIR__ . '/vendor/autoload.php';
$client = new BopData\Client();
$catalog = $client->listDatasets();
$dataset = $client->getDataset($catalog['datasets'][0]['canonicalId']);
print_r($dataset['data']);
```

A dedicated distribution mirror with composer.json at its root is necessary for Packagist. SDK code: MIT; data-source acknowledgement: **BOP Data**; dataset rights are separate.
