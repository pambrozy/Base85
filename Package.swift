// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "Base85",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Base85",
            targets: ["Base85"])
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Base85",
            dependencies: []),
        .testTarget(
            name: "Base85Tests",
            dependencies: ["Base85"])
    ]
)
