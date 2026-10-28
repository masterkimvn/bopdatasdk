# PowerShell example

Run `pwsh -File examples/powershell/dataset.ps1` to discover the first catalog dataset and print its JSON. To select a dataset, pass `-CanonicalId 'your.canonical.id'`. The script validates the ID, uses HTTPS, sets a timeout and reports connection or HTTP failures. Requires PowerShell 7 and network access to data.bop.ink.
