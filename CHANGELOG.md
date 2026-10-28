# Changelog

All notable changes to the **BOP Data SDK repository** are documented here.

This changelog tracks **GitHub source releases**. The SDKs in `packages/` may have independent package names and versions. A GitHub repository release does not imply publication to npm, PyPI, Maven Central, NuGet, Packagist, crates.io, RubyGems, pub.dev, or any other package registry.

## [1.0.0] - 2026-10-28

First public GitHub source release of the BOP Data SDK.

### Added

- **11 read-only API clients:** JavaScript/TypeScript, Python, PHP, Go, Java, C#/.NET, Rust, Ruby, Kotlin/JVM, Swift, and Dart.
- Common operations to browse the public BOP Data dataset catalog, retrieve a dataset by canonical ID as JSON, and retrieve CSV.
- Consumer examples for Node.js, Python, PHP, Go, Java, Ruby, .NET, Rust, Kotlin, Swift, Dart and additional integration patterns.
- Framework and mobile examples: React, Vue, Next.js, React Native, Flutter, Android, and SwiftUI.
- Small standalone integration examples for C, C++, R, PowerShell, and shell.
- Multi-runtime GitHub Actions CI, synthetic API contract tests, and consumer checks.
- [README](README.md) as the public introduction to BOP Data and the SDK.
- [AGENTS.md](AGENTS.md) for third-party AI coding agents.
- Documentation for client methods, practical examples, dataset rights, and release procedures.

### Scope and known limitations

- This is a **v1.0.0 GitHub source-code release**, not a registry release of each language package. Some local package manifests retain development identifiers such as `0.1.0`, `*-local`, or `-SNAPSHOT`. **Do not infer registry availability or a package version of 1.0.0.**
- Android and iOS example apps have not been run on physical devices or simulators as part of the handoff. React Native device compatibility remains unverified.
- Direct browser requests to `data.bop.ink` depend on the upstream API's CORS policy; browser cross-origin support is not guaranteed.
- A public SDK source license has not yet been finalized. **Public source visibility is not a grant of reuse, redistribution, or modification rights.** Check project licensing before reusing code.
- Dataset content and its original sources have separate license, attribution, and redistribution rules. Check the dataset's `provenance` and source terms.
- No SDK package has been published to a public package registry as part of this release.

### Core responsibility

**BOP Data** ([data.bop.ink](https://data.bop.ink)) is the public, non-profit, ad-free structured dataset source. **BOP Data SDK** only connects applications to that source; it does not validate dataset facts, manage upstream data, or run a data backend.

Please credit the dataset source as **BOP Data** when using it; linking to the source is appreciated but optional for that project-level acknowledgement. Individual dataset licensing obligations may be different.

[1.0.0]: https://github.com/masterkimvn/bopdatasdk/releases/tag/v1.0.0
