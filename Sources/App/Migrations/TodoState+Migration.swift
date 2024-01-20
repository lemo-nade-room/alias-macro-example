import Fluent

extension Todo.State {
  struct Migration: AsyncMigration {
    func prepare(on database: Database) async throws {
      _ = try await database.enum("todo_states")
        .case("todo")
        .case("doing")
        .case("done")
        .create()
    }

    func revert(on database: Database) async throws {
      try await database.enum("todo_states").delete()
    }
  }
}
