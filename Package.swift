// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to
// build this package.

import PackageDescription

let package = Package(
    name: "TorrentRSS",
    products: [
        // Products define the executables and libraries produced by a package,
        // and make them visible to other packages.
        .library(
            name: "TorrentRSS",
            targets: ["TorrentRSS"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(
            url: "https://github.com/gcharita/XMLMapper.git",
            from: "1.6.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "3.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can
        // define a module or a test suite.
        // Targets can depend on other targets in this package, and on products
        // in packages which this package depends on.
        .target(
            name: "TorrentRSS",
            dependencies: ["XMLMapper", "Yams"]),
        .testTarget(
            name: "TorrentRSSTests",
            dependencies: ["TorrentRSS"]),
    ]
)
