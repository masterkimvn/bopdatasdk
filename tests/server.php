<?php
$p = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
foreach ([404, 429, 503] as $code) if (str_contains($p, '/status' . $code . '.')) { http_response_code($code); return; }
if (str_contains($p, '/invalid.')) { echo '{'; return; }
if (str_contains($p, '/wrong.')) { echo '{"spec":"unknown"}'; return; }
if (str_contains($p, '/slow.')) { usleep(500000); }
if (str_ends_with($p, '.csv')) { echo "\xef\xbb\xbfa,\"Việt\"\r\n"; return; }
readfile(__DIR__ . '/fixtures/' . (str_ends_with($p, '/datasets.json') ? 'catalog.json' : 'dataset.json'));
