<?php
declare(strict_types=1);
function readBop(string $url): array {
    $ch = curl_init($url);
    curl_setopt_array($ch, [CURLOPT_RETURNTRANSFER => true, CURLOPT_TIMEOUT => 10, CURLOPT_FOLLOWLOCATION => false]);
    $body = curl_exec($ch); $status = curl_getinfo($ch, CURLINFO_RESPONSE_CODE); curl_close($ch);
    if ($body === false || $status < 200 || $status >= 300) throw new RuntimeException('Request failed: HTTP ' . $status);
    return json_decode($body, true, 512, JSON_THROW_ON_ERROR);
}
$catalog = readBop('https://data.bop.ink/api/v1/datasets.json');
$id = $catalog['datasets'][0]['canonicalId'];
if (!preg_match('/\A[A-Za-z0-9._-]{3,}\z/D', $id)) throw new RuntimeException('Invalid canonical ID');
$dataset = readBop('https://data.bop.ink/api/v1/datasets/' . rawurlencode($id) . '.json');
print_r([$dataset['freshness'], $dataset['provenance']]);
