import Fluent
import Vapor

struct TodoController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let todos = routes.grouped("todo")
    todos.get(use: all)

    let todo = todos.grouped(":id")
    todo.post(use: create)
    todo.put(use: update)
    todo.delete(use: delete)
  }

  /// すべてのTodoを取得するクエリパラメータ
  struct TodoAllGetQueryParameter: Content {
    var categoryId: UUID?
  }
  /// すべてのTodoを返す。
  ///
  /// クエリパラメータでカテゴリで制限することもできる
  ///
  /// 順序はカテゴリ名→Todoタイトル
  func all(req: Request) async throws -> [Todo] {
    //    try TodoAllGetQueryParameter.validate(query: req)
    let queryParameter = try req.query.decode(TodoAllGetQueryParameter.self)

    var todoQuery = Todo.query(on: req.db)
    if let categoryId = queryParameter.categoryId {
      todoQuery = todoQuery.filter(\.$category.$id == categoryId)
    }
    return
      try await todoQuery
      .join(Category.self, on: \Category.$id == \Todo.$category.$id, method: .inner)
      .sort(Category.self, \.$name)
      .sort(\.$title)
      .all()
  }

  struct EditTodoJSON: Content, Validatable {
    var categoryId: UUID
    var title: String
    var note: String
    var state: Todo.State

    static func validations(_ validations: inout Vapor.Validations) {
      validations.add("categoryId", as: UUID.self)
      validations.add("title", as: String.self, is: .count(1...255))
      validations.add("note", as: String.self, is: .count(1...10000))
      validations.add("state", as: String.self, is: .in(Todo.State.allCases.map { $0.rawValue }))
    }
  }

  /// Todoを作成する
  func create(req: Request) async throws -> HTTPStatus {
    let id = try req.parameters.require("id", as: UUID.self)
    guard try await Todo.find(id, on: req.db) == nil else {
      throw Abort(.ok, reason: "The todo already exists")
    }

    try EditTodoJSON.validate(content: req)
    let content = try req.content.decode(EditTodoJSON.self)
    guard let category = try await Category.find(content.categoryId, on: req.db) else {
      throw Abort(.ok, reason: "The category does not exist")
    }

    try await Todo(
      id: category.id,
      categoryId: category.requireID(),
      title: content.title,
      note: content.note,
      state: content.state
    ).create(on: req.db)

    return .noContent
  }

  /// Todoを変更する
  func update(req: Request) async throws -> HTTPStatus {
    let id = try req.parameters.require("id", as: UUID.self)
    guard let todo = try await Todo.find(id, on: req.db) else {
      throw Abort(.ok, reason: "The todo does not exist")
    }

    try EditTodoJSON.validate(content: req)
    let content = try req.content.decode(EditTodoJSON.self)
    guard let category = try await Category.find(content.categoryId, on: req.db) else {
      throw Abort(.ok, reason: "The category does not exist")
    }

    todo.$category.id = try category.requireID()
    todo.title = content.title
    todo.note = content.note
    todo.state = content.state
    try await todo.update(on: req.db)

    return .noContent
  }

  /// Todoを削除する
  func delete(req: Request) async throws -> HTTPStatus {
    let id = try req.parameters.require("id", as: UUID.self)
    guard let todo = try await Todo.find(id, on: req.db) else {
      throw Abort(.ok, reason: "The todo does not exist")
    }
    try await todo.delete(on: req.db)
    return .noContent
  }
}
