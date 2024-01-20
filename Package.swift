// swift-tools-version:5.9
import PackageDescription

let package = Package(
  name: "alias",
  platforms: [
    .macOS(.v13)
  ],
  dependencies: [
    // 💧 A server-side Swift web framework.
    .package(url: "https://github.com/vapor/vapor.git", from: "4.89.0"),
    // 🗄 An ORM for SQL and NoSQL databases.
    .package(url: "https://github.com/vapor/fluent.git", from: "4.8.0"),
    // 🐘 Fluent driver for Postgres.
    .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.7.2"),
    // Alias Macro
    .package(url: "https://github.com/p-x9/AliasMacro.git", from: "0.6.0"),
  ],
  targets: [
    .executableTarget(
      name: "App",
      dependencies: [
        .product(name: "Fluent", package: "fluent"),
        .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
        .product(name: "Vapor", package: "vapor"),
        // Alias Macro
        .product(name: "Alias", package: "AliasMacro"),
      ]
    ),
    .testTarget(
      name: "AppTests",
      dependencies: [
        .target(name: "App"),
        .product(name: "XCTVapor", package: "vapor"),

        // Workaround for https://github.com/apple/swift-package-manager/issues/6940
        .product(name: "Vapor", package: "vapor"),
        .product(name: "Fluent", package: "Fluent"),
        .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
      ]),
  ]
)
