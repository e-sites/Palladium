// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Palladium",
    platforms: [
        .iOS(.v10),
    ],
    products: [
        .library(name: "Palladium", targets: ["Palladium"])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Palladium",
            dependencies: [
            ],
            path: "Palladium"
        )
    ],
    swiftLanguageVersions: [ .v5 ]
)
