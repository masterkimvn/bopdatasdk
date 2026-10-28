# Examples

From the repository root:

- JavaScript: `node examples/javascript-node/main.js`
- Python: `PYTHONPATH=packages/python/src python3 examples/python/main.py`
- PHP: `php examples/php/vanilla.php` (requires cURL); for the package example, run `composer install --working-dir=packages/php` then `php examples/php/composer.php`
- Go: `cd packages/go && go run ./examples`

Each example reads the catalog and then fetches its first dataset. Network access to data.bop.ink is required.
