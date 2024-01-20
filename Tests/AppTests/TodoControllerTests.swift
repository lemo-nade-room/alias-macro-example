import Fluent
import XCTVapor

@testable import App

final class TodoControllerTests: XCTestCase {
  func testすべてのTodoを取得() async throws {
    // Arrange
    let app = Application(.testing)
    defer { app.shutdown() }
    try await configure(app)
    try await seed(on: app.db)

    // Act
    try app.test(.GET, "todo") { res in
      // Assert
      XCTAssertEqual(res.status, .ok)
      let todos = try res.content.decode([Todo].self)
      let todoTitles = todos.map { $0.title }
      XCTAssertEqual(todoTitles, ["Web APIテストの実装", "理科の問題集", "国語の宿題", "数学の宿題"])
    }
  }

  func test特定のカテゴリのTodoを取得() async throws {
    // Arrange
    let app = Application(.testing)
    defer { app.shutdown() }
    try await configure(app)
    try await seed(on: app.db)

    // Act
    try app.test(.GET, "todo") { req in
      try req.query.encode(["categoryId": categories[0].requireID()])
    } afterResponse: { res in
      // Assert
      XCTAssertEqual(res.status, .ok)
      let todos = try res.content.decode([Todo].self)
      let todoTitles = todos.map { $0.title }
      XCTAssertEqual(todoTitles, ["国語の宿題", "数学の宿題"])
    }
  }

  func test新しいTodoを作成() async throws {
    // Arrange
    let app = Application(.testing)
    defer { app.shutdown() }
    try await configure(app)
    try await seed(on: app.db)

    let newTodoId = UUID()

    // Act
    try app.test(.POST, "todo/\(newTodoId)") { req in
      try req.content.encode([
        "categoryId": try categories[0].requireID().uuidString,
        "title": "物理の宿題",
        "note": "p.14",
        "state": "todo",
      ])
      req.headers.contentType = .json
    } afterResponse: { res in
      // Assert
      XCTAssertEqual(res.status, .noContent)
      try app.test(.GET, "todo") { res in
        XCTAssertEqual(res.status, .ok)
        let todos = try res.content.decode([Todo].self)
        let todoTitles = todos.map { $0.title }
        XCTAssertEqual(todoTitles, ["Web APIテストの実装", "理科の問題集", "国語の宿題", "数学の宿題", "物理の宿題"])
      }
    }
  }

  func testTodoを変更() async throws {
    // Arrange
    let app = Application(.testing)
    defer { app.shutdown() }
    try await configure(app)
    try await seed(on: app.db)

    // Act
    try app.test(.PUT, "todo/\(todos[0].requireID())") { req in
      try req.content.encode([
        "categoryId": try categories[0].requireID().uuidString,
        "title": "物理の宿題",
        "note": "p.14",
        "state": "todo",
      ])
      req.headers.contentType = .json
    } afterResponse: { res in
      // Assert
      XCTAssertEqual(res.status, .noContent)
      try app.test(.GET, "todo") { res in
        XCTAssertEqual(res.status, .ok)
        let todos = try res.content.decode([Todo].self)
        let todoTitles = todos.map { $0.title }
        XCTAssertEqual(todoTitles, ["Web APIテストの実装", "理科の問題集", "国語の宿題", "物理の宿題"])
      }
    }
  }

  func testTodoを削除() async throws {
    // Arrange
    let app = Application(.testing)
    defer { app.shutdown() }
    try await configure(app)
    try await seed(on: app.db)

    // Act
    try app.test(.DELETE, "todo/\(todos[0].requireID())") { res in
      // Assert
      print(res.body.string)
      XCTAssertEqual(res.status, .noContent)
      try app.test(.GET, "todo") { res in
        XCTAssertEqual(res.status, .ok)
        let todos = try res.content.decode([Todo].self)
        let todoTitles = todos.map { $0.title }
        XCTAssertEqual(todoTitles, ["Web APIテストの実装", "理科の問題集", "国語の宿題"])
      }
    }
  }
}
