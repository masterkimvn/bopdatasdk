<?php
require __DIR__ . '/../../packages/php/src/Client.php';
$client = new BopData\Client();
$catalog = $client->listDatasets();
$dataset = $client->getDataset($catalog['datasets'][0]['canonicalId']);
print_r([$dataset['freshness'], $dataset['provenance']]);
