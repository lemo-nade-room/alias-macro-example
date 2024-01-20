import Fluent
import Vapor

struct CategoryController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let categories = routes.grouped("category")
    categories.get(use: all)

    let category = categories.grouped(":id")
    category.post(use: create)
    category.put(use: update)
    category.delete(use: delete)
  }

  /// すべてのカテゴリを返す
  func all(req: Request) async throws -> [Category] {
    try await Category.query(on: req.db).sort(\.$name).all()
  }

  /// カテゴリ編集用JSON型
  struct EditCategoryJSON: Content, Validatable {
    var name: String

    static func validations(_ validations: inout Vapor.Validations) {
      validations.add("name", as: String.self, is: .count(1...255))
    }
  }

  /// カテゴリを作成する
  func create(req: Request) async throws -> HTTPStatus {
    let id = try req.parameters.require("id", as: UUID.self)
    guard try await Category.find(id, on: req.db) == nil else {
      throw Abort(.ok, reason: "The category already exists")
    }
    try EditCategoryJSON.validate(content: req)
    let content = try req.content.decode(EditCategoryJSON.self)
    try await Category(id: id, name: content.name).create(on: req.db)
    return .noContent
  }

  /// カテゴリを変更する
  func update(req: Request) async throws -> HTTPStatus {
    let id = try req.parameters.require("id", as: UUID.self)
    guard let category = try await Category.find(id, on: req.db) else {
      throw Abort(.ok, reason: "The category does not exist")
    }
    try EditCategoryJSON.validate(content: req)
    let content = try req.content.decode(EditCategoryJSON.self)
    category.name = content.name
    try await category.update(on: req.db)
    return .noContent
  }

  /// カテゴリを削除する
  func delete(req: Request) async throws -> HTTPStatus {
    let id = try req.parameters.require("id", as: UUID.self)
    guard let category = try await Category.find(id, on: req.db) else {
      throw Abort(.ok, reason: "The category does not exist")
    }
    try await req.db.transaction { transaction in
      try await Todo.query(on: transaction)
        .filter(\.$category.$id == (try category.requireID()))
        .delete()
      try await category.delete(on: transaction)
    }
    return .noContent
  }
}
