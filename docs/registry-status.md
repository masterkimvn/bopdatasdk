# Registry distribution — preparation and publication status

**GitHub repository:** https://github.com/masterkimvn/bopdatasdk  
**Repository source release:** v1.0.0 (already publicly available).  
**Registry distributions:** source packages and workflows are prepared; **nothing below is claimed to be published to a registry** until checked independently.

| Language | Candidate name / coordinates | Registry | First-publication requirement |
| --- | --- | --- | --- |
| JavaScript / TypeScript | `bop-data-sdk` | npm | Claim package name and perform first publish with owner credentials; configure trusted publisher afterward |
| Python | `bop-data-sdk` | PyPI | Set up pending Trusted Publisher for `publish-python.yml` |
| PHP | `bopink/data-sdk` | Packagist | Export and register PHP-only GitHub mirror (composer.json at root) |
| Go | `github.com/masterkimvn/bopdatasdk/packages/go` | Go modules | After verified merge and CI, push `packages/go/v1.0.0` and check `go list` |
| Java | `ink.bop:data-sdk:1.0.0` | Maven Central | Verify namespace ownership, set credentials + GPG signing, submit signed bundle |
| Kotlin | `ink.bop:data-kotlin:1.0.0` | Maven Central | Same requirements as Java; validate Kotlin artifact including sources and Javadoc |
| C# / .NET | `BopData.SDK` | NuGet | Claim package ID, set registry API-key secret |
| Rust | `bop-data-sdk` | crates.io | Verify name, configure crates.io API token |
| Ruby | `bop-data-sdk` | RubyGems | Configure pending Trusted Publisher for `publish-ruby.yml` |
| Dart / Flutter | `bop_data_sdk` | pub.dev | First publish manually; tag-based GitHub OIDC only after package exists |
| Swift | `BopData` | Swift Package Manager | Export Swift-only mirror with Package.swift at repo root, then tag version |

These package identities are **candidates**, not proof that a registry name is available. Adjust the name if the registry reports a conflict before publishing and update references/tests consistently.

## Safe setup

1. Confirm registry account ownership and name availability.
2. Configure a GitHub Environment named **`registry-publish`** with required reviewers and only approved source branches/tags.
3. Configure a Trusted Publisher or scoped secret as directed by the target registry. Never commit passwords or tokens.
4. Run GitHub CI and [registry packaging preflight](../.github/workflows/registry-preflight.yml); inspect the built artifact.
5. Explicitly initiate only the workflow for the package being released. Test installation from a clean project and retrieve an actual BOP Data dataset.
6. Record the **verified registry link, version, date, and install command** here before claiming publication in README.

## Registry credentials and configurations

- npm: owner account; trusted publisher workflow filename `publish-javascript.yml`. Initial npm publication may require interactive owner credentials; use Node 24 and npm CLI supporting OIDC.
- PyPI: pending trusted publisher project `bop-data-sdk`, GitHub `masterkimvn/bopdatasdk`, workflow `publish-python.yml`, environment `registry-publish`. No long-lived token.
- RubyGems: pending trusted publisher project `bop-data-sdk`, same GitHub repository, workflow `publish-ruby.yml`, environment `registry-publish`. No long-lived token.
- crates.io: GitHub environment secret `CRATES_IO_TOKEN` scoped to the registry.
- NuGet: GitHub environment secret `NUGET_API_KEY` scoped to the package ID.
- Maven Central: verify namespace `ink.bop`; set environment secrets `CENTRAL_TOKEN_USERNAME`, `CENTRAL_TOKEN_PASSWORD`, `MAVEN_GPG_PRIVATE_KEY`, `MAVEN_GPG_PASSPHRASE`. Workflow submits a bundle for **manual Central Portal approval**, not automatic publication.
- pub.dev: perform the first upload through `dart pub publish` as package owner, then enable pub.dev GitHub automated publishing for repository `masterkimvn/bopdatasdk` and tag pattern `packages/dart/v{{version}}`.
- PHP + Swift: `bash scripts/export-package.sh php /tmp/output` or `swift` generates clean source for dedicated public mirror repos that the owner must create and own. Do not assume a nonexistent mirror URL.

## Rights and attribution

SDK source is [MIT](../LICENSE) licensed; dataset usage terms are independent. We request the visible credit **BOP Data**, with a link appreciated but not mandatory. See [license scope](license-scope.md).
