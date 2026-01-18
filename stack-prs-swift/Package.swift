// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "stack-prs",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "stack-prs", targets: ["StackPRs"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.3")
    ],
    targets: [
        .executableTarget(
            name: "StackPRs",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        )
    ]
)
