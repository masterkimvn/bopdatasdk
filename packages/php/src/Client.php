<?php
declare(strict_types=1);
namespace BopData;

class Client {
    private string $baseUrl;
    private int $timeoutMs;
    public function __construct(string $baseUrl = 'https://data.bop.ink', int $timeoutMs = 10000) {
        $u = parse_url($baseUrl);
        if (!$u || !in_array($u['scheme'] ?? '', ['http', 'https'], true) || empty($u['host']) || (isset($u['user']) || isset($u['pass'])) || isset($u['query']) || isset($u['fragment']) || $timeoutMs <= 0) throw new \InvalidArgumentException('Invalid client configuration');
        $this->baseUrl = rtrim($baseUrl, '/'); $this->timeoutMs = $timeoutMs;
    }
    private function id(string $id): string {
        if (!preg_match('/\A[A-Za-z0-9._-]{3,}\z/D', $id)) throw new \InvalidArgumentException('Invalid canonical ID');
        return rawurlencode($id);
    }
    private function request(string $path, ?string $spec = null): mixed {
        $ch = curl_init($this->baseUrl . $path);
        curl_setopt_array($ch, [CURLOPT_RETURNTRANSFER => true, CURLOPT_TIMEOUT_MS => $this->timeoutMs, CURLOPT_FOLLOWLOCATION => false]);
        $body = curl_exec($ch); $errno = curl_errno($ch); $status = curl_getinfo($ch, CURLINFO_RESPONSE_CODE); curl_close($ch);
        if ($body === false) throw new \RuntimeException($errno === CURLE_OPERATION_TIMEDOUT ? 'Request timed out' : 'Request failed');
        if ($status < 200 || $status >= 300) throw new \RuntimeException('HTTP ' . $status, $status);
        if ($spec === null) return $body;
        try { $value = json_decode($body, true, 512, JSON_THROW_ON_ERROR); } catch (\JsonException $e) { throw new \RuntimeException('Invalid JSON response', 0, $e); }
        if (!is_array($value) || ($value['spec'] ?? null) !== $spec) throw new \RuntimeException('Incompatible response spec');
        return $value;
    }
    public function listDatasets(): array { return $this->request('/api/v1/datasets.json', 'bop.catalog/1'); }
    public function getDataset(string $id): array { return $this->request('/api/v1/datasets/' . $this->id($id) . '.json', 'bop.dataset/1'); }
    public function getDatasetCsv(string $id): string { return $this->request('/api/v1/datasets/' . $this->id($id) . '.csv'); }
}
