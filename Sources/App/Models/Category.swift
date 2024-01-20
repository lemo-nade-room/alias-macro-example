import Fluent
import Vapor
import Alias

final class Category: Model, Content {
  static let schema = "categories"

  @ID
  var id: UUID?

  @Alias("名前")
  @Field(key: "name")
  var name: String

  @Timestamp(key: "created_at", on: .create)
  var createdAt: Date?

  @Timestamp(key: "updated_at", on: .update)
  var updatedAt: Date?

  init() {}

  init(id: UUID = .init(), name: String) {
    self.id = id
    self.name = name
  }
}
