# BOP Data SDK — Source and registry release process

## GitHub source release

The original [v1.0.0 source release](https://github.com/masterkimvn/bopdatasdk/releases/tag/v1.0.0) is available and remains unchanged. It represents the repository snapshot at the October 28, 2026 tag. Later source commits that prepare registry-specific packages do **not** retroactively change that tag.

## Independent language packages

This repository now contains proposed first registry package metadata for eleven SDKs, with MIT licensed SDK code. That is **not** proof that the packages have been published to public registries.

Read [registry status and first-publish checklist](registry-status.md). Each publish workflow is separately gated by an explicit human confirmation or a package-specific tag. Create the protected GitHub environment `registry-publish` with reviewers before adding any publication secrets.

- **npm:** First claim/publish the package under the owner account. Then configure npm Trusted Publisher (`publish-javascript.yml`) and run the workflow manually. Confirm npm CLI and Node versions support OIDC.
- **PyPI:** Register a pending Trusted Publisher (`publish-python.yml`, GitHub repository `masterkimvn/bopdatasdk`, environment `registry-publish`) and run the workflow manually.
- **RubyGems:** Register a pending Trusted Publisher (`publish-ruby.yml`, same GitHub repo/environment) and run the workflow manually.
- **NuGet / crates.io:** Set the narrowly scoped `NUGET_API_KEY` / `CRATES_IO_TOKEN` secret and manually invoke the respective publishing workflow.
- **Maven Central:** Verify ownership of the `ink.bop` namespace and establish a Sonatype Central Portal account. Supply signed release credentials via GitHub environment secrets. The Maven workflow **submits** for manual portal validation/approval; Java and Kotlin artifacts must be inspected.
- **pub.dev:** The **first** release must be published manually. Later releases can use OIDC from a GitHub tag matching `packages/dart/v{{version}}` and the `publish-dart.yml` workflow.
- **Go:** The nested module needs a scoped tag `packages/go/v1.0.0` on an approved commit, not the root `v1.0.0` tag. Confirm the module resolves through Go proxy before advertising it.
- **PHP / Swift:** Export their directories with `bash scripts/export-package.sh php|swift /tmp/output` and create public mirrors where their manifests are at repository root; tags and mirror registration follow after owner review.

## Release quality gate

For every package:

1. Confirm registry account ownership and proposed package name availability.
2. Build/inspect artifact with package-specific tools and [registry preflight](../.github/workflows/registry-preflight.yml).
3. Run relevant SDK and installed-consumer tests with synthetic API fixtures.
4. Explicitly publish, then independently verify the exact version and clean-install from the public registry.
5. Fetch a real catalog/dataset when network connectivity allows, and document limitations without claiming correctness audits.
6. Only after verifying installation, update README with public installation commands and registry links.

## Rights and attribution

[MIT](../LICENSE) covers **SDK code**, not datasets, original sources, or branding. Credit **BOP Data** as source when using datasets (link appreciated but optional for this project request). Follow original dataset-specific terms. See [license scope](license-scope.md).
