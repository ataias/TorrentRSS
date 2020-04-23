import XCTest
@testable import torrent_rss

final class torrent_rssTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(torrent_rss().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
