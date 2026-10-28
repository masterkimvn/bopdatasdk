# Swift client

This Swift package is under development and has not been published. Add `packages/swift` as a local Swift package in Xcode, then `import BopData`. `BopDataClient` provides asynchronous `listDatasets()`, `getDataset(_:)` and `getDatasetCSV(_:)`. JSON returns dictionaries preserving extra fields; CSV returns `Data`. Requires iOS 15 or macOS 12 and Swift 5.9 or later. See `examples/swift/DatasetView.swift` for a SwiftUI view.

The package and a live consumer have been tested on Linux Swift. An iOS simulator build is not yet verified.
