param([string]$CanonicalId)
$ErrorActionPreference = 'Stop'
$base = 'https://data.bop.ink/api/v1/datasets'
try {
    if (-not $CanonicalId) {
        $catalog = Invoke-RestMethod -Uri "$base.json" -TimeoutSec 10
        if (-not $catalog.datasets -or $catalog.datasets.Count -eq 0) { throw 'The catalog is empty' }
        $CanonicalId = $catalog.datasets[0].canonicalId
    }
    if ($CanonicalId -cnotmatch '\A[A-Za-z0-9._-]{3,}\z') { throw 'Invalid canonical ID' }
    $dataset = Invoke-RestMethod -Uri "$base/$CanonicalId.json" -TimeoutSec 10
    $dataset | ConvertTo-Json -Depth 100
} catch {
    Write-Error "Unable to retrieve BOP Data: $($_.Exception.Message)"
    exit 1
}
