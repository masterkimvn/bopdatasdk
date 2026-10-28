# Release preparation

The clients are not published. Package names, namespace ownership, license and copyright holder must be confirmed before release. Version numbers may be managed independently. Do not publish or create tags until the release and its destinations are approved.

Build and inspect the JavaScript tarball with `npm pack --dry-run` in `packages/javascript`; build the Python wheel and source distribution with `python -m build` in `packages/python`. Validate the PHP package with Composer. Run `go test ./...` and `go vet ./...` in `packages/go`. Install artifacts into clean consumer projects and inspect their contents before publication. The Go module's version tag must have the prefix `packages/go/`, for example `packages/go/v0.1.0`.

Configure registry trusted publishing according to current registry documentation and grant identity permissions only to the publishing job. After an approved release, verify installation from each public registry. Dataset rights remain separate from the SDK license.
