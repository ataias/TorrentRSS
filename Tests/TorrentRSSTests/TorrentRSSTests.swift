import XCTest
@testable import TorrentRSS

final class TorrentRSSTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(TorrentRSS().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
