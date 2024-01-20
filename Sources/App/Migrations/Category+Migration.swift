import Fluent

extension Category {
  struct Migration: AsyncMigration {
    func prepare(on database: Database) async throws {
      try await database.schema("categories")
        .id()
        .field("name", .string, .required)
        .field("created_at", .datetime, .required)
        .field("updated_at", .datetime, .required)
        .create()
    }

    func revert(on database: Database) async throws {
      try await database.schema("categories").delete()
    }
  }
}
