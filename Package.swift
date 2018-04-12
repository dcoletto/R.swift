// swift-tools-version:4.0
import PackageDescription

let package = Package(
  name: "rswift",
  dependencies: [
    .package(url: "https://github.com/kylef/Commander.git", from: "0.8.0"),
    .package(url: "https://github.com/tomlokhorst/XcodeEdit", from: "2.1.0"),
    .package(url: "https://github.com/drmohundro/SWXMLHash.git", from: "4.0.0")
  ],
  targets: [
    .target(
      name: "rswift",
      dependencies: ["RswiftCore"]
    ),
    .target(
      name: "RswiftCore",
      dependencies: ["Commander", "XcodeEdit", "SWXMLHash"]
    ),
    .testTarget(name: "RswiftCoreTests", dependencies: ["RswiftCore"]),
  ],
  swiftLanguageVersions: [4]
)
