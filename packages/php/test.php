<?php
require __DIR__ . '/src/Client.php';
$c = new BopData\Client('http://127.0.0.1:18764');
assert($c->listDatasets()['total'] === 2);
$d = $c->getDataset('test.one');
assert($d['future'] === 'preserved' && $d['freshness']['lastUpdated'] === null && $d['provenance']['license'] === 'synthetic');
assert(str_starts_with($c->getDatasetCsv('test.one'), "\xef\xbb\xbf"));
foreach (['', 'a/b', 'https://x', 'đxx'] as $id) { try { $c->getDataset($id); throw new Exception('invalid ID accepted'); } catch (InvalidArgumentException $e) {} }
foreach ([404, 429, 503] as $status) { try { $c->getDataset('status'.$status); throw new Exception('status accepted'); } catch (RuntimeException $e) { assert($e->getCode() === $status); } }
foreach (['invalid', 'wrong'] as $id) { try { $c->getDataset($id); throw new Exception('bad response accepted'); } catch (RuntimeException $e) {} }
try { (new BopData\Client('http://127.0.0.1:18764', 30))->getDataset('slow'); throw new Exception('timeout accepted'); } catch (RuntimeException $e) { assert($e->getMessage() === 'Request timed out'); }
