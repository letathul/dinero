// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Dinero",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(
            name: "Dinero",
            targets: ["Dinero"]
        ),
    ],
    targets: [
        .target(
            name: "Dinero",
            path: "Dinero/Sources"
        ),
    ]
)
