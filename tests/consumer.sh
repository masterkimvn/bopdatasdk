#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
php -S 127.0.0.1:18765 "$root/tests/server.php" >"$tmp/server.log" 2>&1 &
pid=$!
trap 'kill "$pid" 2>/dev/null || true; rm -rf "$tmp"' EXIT
sleep 1
(cd "$root/packages/javascript" && npm pack --pack-destination "$tmp" >/dev/null)
mkdir "$tmp/js"
(cd "$tmp/js" && npm install --no-audit --no-fund "$tmp"/*.tgz >/dev/null)
cat > "$tmp/js/check.mjs" <<'JS'
import {BopDataClient} from 'bop-data-sdk';
const c = new BopDataClient({baseUrl:'http://127.0.0.1:18765'});
if ((await c.listDatasets()).total !== 2 || (await c.getDataset('test.one')).provenance.license !== 'synthetic' || !(await c.getDatasetCsv('test.one')).startsWith('\ufeff')) throw Error('JS consumer');
JS
(cd "$tmp/js" && node check.mjs)
python3 -m build --outdir "$tmp/dist" "$root/packages/python" >/dev/null
python3 -m venv "$tmp/venv"
"$tmp/venv/bin/pip" install --no-deps "$tmp"/dist/*.whl >/dev/null
(cd "$tmp" && "$tmp/venv/bin/python" -c "from bop_data import BopDataClient; c=BopDataClient('http://127.0.0.1:18765'); assert c.list_datasets()['total']==2 and c.get_dataset('test.one')['provenance']['license']=='synthetic' and c.get_dataset_csv('test.one').startswith('\ufeff')")
mkdir "$tmp/php"
printf '{"repositories":[{"type":"path","url":"%s/packages/php","options":{"symlink":false}}],"require":{"bopink/data-sdk":"dev-main"}}\n' "$root" > "$tmp/php/composer.json"
COMPOSER_ALLOW_SUPERUSER=1 composer install -d "$tmp/php" --no-interaction --no-progress >/dev/null
cat > "$tmp/php/check.php" <<'PHP'
<?php
require __DIR__.'/vendor/autoload.php';
$c = new BopData\Client('http://127.0.0.1:18765');
if ($c->listDatasets()['total'] !== 2 || $c->getDataset('test.one')['provenance']['license'] !== 'synthetic' || !str_starts_with($c->getDatasetCsv('test.one'), "\xef\xbb\xbf")) throw new Exception('PHP consumer');
PHP
php "$tmp/php/check.php"
mkdir "$tmp/go"
printf 'module example.com/consumer\n\ngo 1.21\n\nrequire github.com/masterkimvn/bopdatasdk/packages/go v0.0.0\nreplace github.com/masterkimvn/bopdatasdk/packages/go => %s/packages/go\n' "$root" > "$tmp/go/go.mod"
cat > "$tmp/go/main.go" <<'GO'
package main
import ("context"; "fmt"; b "github.com/masterkimvn/bopdatasdk/packages/go")
func main() { c:=b.NewClient(); c.BaseURL="http://127.0.0.1:18765"; cat,e:=c.ListDatasets(context.Background()); if e!=nil || string(cat["total"])!="2" { panic("catalog") }; d,e:=c.GetDataset(context.Background(),"test.one"); if e!=nil || len(d["provenance"])==0 { panic("dataset") }; csv,e:=c.GetDatasetCSV(context.Background(),"test.one"); if e!=nil || len(csv)<3 || string(csv[:3])!="\xef\xbb\xbf" { panic("csv") }; fmt.Println("consumer checks passed") }
GO
(cd "$tmp/go" && go run .)
python3 - "$tmp" <<'PY'
import pathlib, sys, tarfile, zipfile
p = pathlib.Path(sys.argv[1])
for archive in list(p.glob('*.tgz')) + list((p/'dist').glob('*')):
    names = zipfile.ZipFile(archive).namelist() if archive.suffix == '.whl' else tarfile.open(archive).getnames()
    assert not any('work/' in n or n.endswith('.env') for n in names), archive
PY
