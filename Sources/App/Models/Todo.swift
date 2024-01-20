import Fluent
import Vapor

final class Todo: Model, Content {
  static let schema = "todos"

  @ID
  var id: UUID?

  @Parent(key: "category_id")
  var category: Category

  @Field(key: "title")
  var title: String

  @Field(key: "note")
  var note: String

  @Enum(key: "state")
  var state: State

  @Timestamp(key: "created_at", on: .create)
  var createdAt: Date?

  @Timestamp(key: "updated_at", on: .update)
  var updatedAt: Date?

  init() {}

  init(id: UUID? = nil, categoryId: Category.IDValue, title: String, note: String, state: State) {
    self.id = id
    self.$category.id = categoryId
    self.title = title
    self.note = note
    self.state = state
  }
}

extension Todo {
  enum State: String, Hashable, Content, CaseIterable {
    case todo, doing, done
  }
}
