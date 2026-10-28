# Release and distribution

## Current GitHub source release

**Repository version:** v1.0.0 (2026-10-28). See [Changelog](../CHANGELOG.md) and [GitHub release notes](releases/v1.0.0.md).

The GitHub release is a **source-code snapshot** with eleven read-only BOP Data clients, examples, tests, and documentation. It is **not** a release to public language package registries, and it does not deploy or change the production API at `data.bop.ink`.

The existing package manifests deliberately retain local/development names and version numbers. Repository tag `v1.0.0` **does not** change the language-specific package version values, imply registry availability, or certify untested mobile builds.

## Get the tagged source

```bash
git clone --branch v1.0.0 --depth 1 https://github.com/masterkimvn/bopdatasdk.git
cd bopdatasdk
```

Use [client installation instructions](clients.md) and [examples](examples.md) to run a client locally. No BOP Data API key is needed.

## CI and GitHub release

The v1.0.0 GitHub release is created only after the `CI` workflow passes for the main-branch source commit. The one-time release workflow checks that the successful CI commit is the current `main` head before creating the tag and release.

For later releases, update `CHANGELOG.md`, the release notes, and the repository version first; run and confirm CI, then use an explicitly approved release procedure. Do not assume the v1.0.0 one-time workflow handles future versions.

## Separate approval required before public registry publication

- Final SDK source license and copyright information. **No public-use license is granted merely by source visibility.**
- Package names/namespaces and ownership for each target registry.
- Individual package versioning, package metadata, and integrity checks.
- Registry authentication and narrowly scoped publishing permissions.
- Installation and smoke checks from each registry after publication.

Build and inspect source packages independently: `npm pack --dry-run` (JavaScript), `python -m build` (Python), Composer validation (PHP), `go test ./...` and `go vet ./...` (Go), plus each other language's documented checks. Validate package artifacts in clean consumer environments before registry publication.

For a Go release, the nested module may require its own appropriately prefixed tag, e.g. `packages/go/v1.0.0`. The root `v1.0.0` tag does **not** publish that Go module version.

SDK source rights are separate from the rights associated with any dataset's content and original sources. Read [data rights](data-rights.md).
