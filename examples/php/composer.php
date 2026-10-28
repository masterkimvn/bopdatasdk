<?php
declare(strict_types=1);
require __DIR__ . '/../../packages/php/vendor/autoload.php';
$client = new BopData\Client();
$catalog = $client->listDatasets();
$dataset = $client->getDataset($catalog['datasets'][0]['canonicalId']);
print_r([$dataset['freshness'], $dataset['provenance']]);
