// swift-tools-version: 5.9
import PackageDescription
let package = Package(name: "BopData", platforms: [.iOS(.v15), .macOS(.v12)], products: [.library(name: "BopData", targets: ["BopData"])], targets: [.target(name: "BopData"), .testTarget(name: "BopDataTests", dependencies: ["BopData"])])
