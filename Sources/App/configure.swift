import Fluent
import FluentPostgresDriver
import NIOSSL
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
  // uncomment to serve files from /Public folder
  // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

  app.databases.use(
    DatabaseConfigurationFactory.postgres(
      configuration: .init(
        hostname: "127.0.0.1",
        port: 54321,
        username: "vapor_username",
        password: "vapor_password",
        database: "vapor_database",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)

  app.migrations.add(Category.Migration())
  app.migrations.add(Todo.State.Migration())
  app.migrations.add(Todo.Migration())

  // register routes
  try routes(app)
}
