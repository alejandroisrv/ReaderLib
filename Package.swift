// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ReaderLib",
    platforms: [ .iOS("15.0") ],
    products: [
        .library(
            name: "ReaderLib",
            targets: ["ReaderLib"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),

        .package(url: "https://github.com/ZipArchive/ZipArchive.git", from: "2.4.2"),
        .package(url: "https://github.com/cxa/MenuItemKit.git", from: "4.0.0"),
        .package(url: "https://github.com/tadija/AEXML.git", from: "4.6.1"),
        .package(url: "https://github.com/ArtSabintsev/FontBlaster.git", from: "5.2.0"),
        .package(name: "Realm", url: "https://github.com/realm/realm-cocoa.git", from: "10.20.0"),
        .package(url: "https://github.com/tsolomko/SWCompression.git", from: "4.7.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ReaderLib",
            dependencies: ["AEXML", "ZipArchive", "MenuItemKit","FontBlaster", .product(name: "RealmSwift", package: "Realm"), "SWCompression"],
            resources: [ .process("Resources") ]),
        .testTarget(
            name: "ReaderLibTests",
            dependencies: ["ReaderLib"]),
    ]
)
