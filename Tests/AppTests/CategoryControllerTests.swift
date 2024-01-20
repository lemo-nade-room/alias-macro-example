import Fluent
import XCTVapor

@testable import App

final class CategoryControllerTests: XCTestCase {
  func testすべてのカテゴリを取得() async throws {
    // Arrange
    let app = Application(.testing)
    defer { app.shutdown() }
    try await configure(app)
    try await seed(on: app.db)

    // Act
    try app.test(.GET, "category") { res in
      // Assert
      XCTAssertEqual(res.status, .ok)
      let categories = try res.content.decode([App.Category].self)
      let categoryNames = categories.map { $0.name }
      XCTAssertEqual(categoryNames, ["バイト", "塾", "学校"])
    }
  }

  func test新しいカテゴリを作成を取得() async throws {
    // Arrange
    let app = Application(.testing)
    defer { app.shutdown() }
    try await configure(app)
    try await seed(on: app.db)

    let newCategoryId = UUID()

    // Act
    try app.test(.POST, "category/\(newCategoryId)") { req in
      try req.content.encode(["name": "家事"])
      req.headers.contentType = .json
    } afterResponse: { res in
      // Assert
      XCTAssertEqual(res.status, .noContent)
      try app.test(.GET, "category") { res in
        XCTAssertEqual(res.status, .ok)
        let categories = try res.content.decode([App.Category].self)
        let categoryNames = categories.map { $0.name }
        XCTAssertEqual(categoryNames, ["バイト", "塾", "学校", "家事"])
      }
    }
  }

  func testカテゴリを変更() async throws {
    // Arrange
    let app = Application(.testing)
    defer { app.shutdown() }
    try await configure(app)
    try await seed(on: app.db)

    // Act
    try app.test(.PUT, "category/\(categories[0].requireID())") { req in
      try req.content.encode(["name": "School"])
      req.headers.contentType = .json
    } afterResponse: { res in
      // Assert
      XCTAssertEqual(res.status, .noContent)
      try app.test(.GET, "category") { res in
        XCTAssertEqual(res.status, .ok)
        let categories = try res.content.decode([App.Category].self)
        let categoryNames = categories.map { $0.name }
        XCTAssertEqual(categoryNames, ["School", "バイト", "塾"])
      }
    }
  }

  func testカテゴリを削除() async throws {
    // Arrange
    let app = Application(.testing)
    defer { app.shutdown() }
    try await configure(app)
    try await seed(on: app.db)

    // Act
    try app.test(.DELETE, "category/\(categories[0].requireID())") { res in
      // Assert
      XCTAssertEqual(res.status, .noContent)
      try app.test(.GET, "category") { res in
        XCTAssertEqual(res.status, .ok)
        let categories = try res.content.decode([App.Category].self)
        let categoryNames = categories.map { $0.name }
        XCTAssertEqual(categoryNames, ["バイト", "塾"])
      }
    }
  }
}
