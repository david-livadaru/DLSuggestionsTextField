// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DLSuggestionsTextField",
    products: [
        .library(
            name: "DLSuggestionsTextField",
            targets: ["DLSuggestionsTextField"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "DLSuggestionsTextField",
            dependencies: []),
        .testTarget(
            name: "DLSuggestionsTextFieldTests",
            dependencies: ["DLSuggestionsTextField"]),
    ]
)
