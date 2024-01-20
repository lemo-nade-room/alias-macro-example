import Fluent

@testable import App

var categories = [App.Category]()
var todos = [Todo]()

func seed(on db: Database) async throws {
  try await Todo.query(on: db).delete()
  try await Category.query(on: db).delete()

  categories = [
    .init(name: "学校"),
    .init(name: "塾"),
    .init(name: "バイト"),
  ]
  try await categories.create(on: db)

  todos = try [
    .init(categoryId: categories[0].requireID(), title: "数学の宿題", note: "p102〜p103", state: .todo),
    .init(categoryId: categories[0].requireID(), title: "国語の宿題", note: "枕草子", state: .done),
    .init(categoryId: categories[1].requireID(), title: "理科の問題集", note: "p.14", state: .doing),
    .init(
      categoryId: categories[2].requireID(), title: "Web APIテストの実装", note: "GETのみ", state: .todo),
  ]
  try await todos.create(on: db)
}
