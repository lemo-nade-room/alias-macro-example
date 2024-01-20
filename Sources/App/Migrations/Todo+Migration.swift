import Fluent

extension Todo {
  struct Migration: AsyncMigration {
    func prepare(on database: Database) async throws {
      let stateSchema = try await database.enum("todo_states").read()

      try await database.schema("todos")
        .id()
        .field("title", .string, .required)
        .field("note", .string, .required)
        .field("state", stateSchema, .required)
        .field("created_at", .datetime, .required)
        .field("updated_at", .datetime, .required)
        .create()
    }

    func revert(on database: Database) async throws {
      try await database.schema("todos").delete()
    }
  }
}
