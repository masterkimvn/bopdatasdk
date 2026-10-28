#!/usr/bin/env python3
"""Offline registry metadata checks. Does not authenticate to or publish a registry."""
import json
import pathlib
import sys
import tomllib

root = pathlib.Path(__file__).resolve().parents[1]
js = json.loads((root / "packages/javascript/package.json").read_text())
py = tomllib.loads((root / "packages/python/pyproject.toml").read_text())
rs = tomllib.loads((root / "packages/rust/Cargo.toml").read_text())
php = json.loads((root / "packages/php/composer.json").read_text())
errors = []
for label, actual, expected in [
    ("npm", js["name"], "bop-data-sdk"),
    ("PyPI", py["project"]["name"], "bop-data-sdk"),
    ("crates.io", rs["package"]["name"], "bop-data-sdk"),
    ("Packagist", php["name"], "bopink/data-sdk"),
]:
    if actual != expected:
        errors.append(f"{label} name mismatch: {actual}")
for label, version in [("npm", js["version"]), ("PyPI", py["project"]["version"]), ("crates.io", rs["package"]["version"])]:
    if version != "1.0.0":
        errors.append(f"{label} expected version 1.0.0, got {version}")
for label, value in [("npm", js.get("license")), ("PyPI", py["project"].get("license")), ("Rust", rs["package"].get("license"))]:
    if value != "MIT":
        errors.append(f"{label}: expected MIT")
for d in ("javascript", "python", "php", "go", "java", "kotlin", "dotnet", "rust", "ruby", "dart", "swift"):
    if not (root / "packages" / d / "LICENSE").exists():
        errors.append(f"Missing packages/{d}/LICENSE")
if errors:
    print("\n".join(errors), file=sys.stderr)
    sys.exit(1)
print("Metadata preflight passed. No registry publication implied.")
