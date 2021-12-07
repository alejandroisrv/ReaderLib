import XCTest
@testable import ReaderLib

final class ReaderLibTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(ReaderLib().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
