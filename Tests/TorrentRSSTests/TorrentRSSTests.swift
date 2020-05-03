import XCTest
@testable import TorrentRSS

final class TorrentRSSTests: XCTestCase {
    func testFullServerConfig() throws {
        let serverOptionsStr = """
        server: http://myserver.com:9091
        db: ~/.config/trss/trss.db
        secondsTimeout: 20
        username: asdf
        password: abc123456
        """
        let serverOptionsOpt: Config? = Config(yaml: serverOptionsStr)
        let serverOptions = try AssertNotNilAndUnwrap(serverOptionsOpt)
        XCTAssertEqual("\(serverOptions.server)", "http://myserver.com:9091")
        XCTAssertEqual("\(serverOptions.db)", "~/.config/trss/trss.db")
        XCTAssertEqual(serverOptions.secondsTimeout!, 20)
        XCTAssertEqual(serverOptions.username!, "asdf")
        XCTAssertEqual(serverOptions.password!, "abc123456")
    }

    func testPartialConfig() throws {
        let serverOptionsStr = """
        server: http://myserver.com:9091
        db: ~/.config/trss/trss.db
        """
        let serverOptionsOpt: Config? = Config(yaml: serverOptionsStr)
        let serverOptions = try AssertNotNilAndUnwrap(serverOptionsOpt)
        XCTAssertEqual("\(serverOptions.server)", "http://myserver.com:9091")
        XCTAssertNil(serverOptions.secondsTimeout)
        XCTAssertNil(serverOptions.username)
        XCTAssertNil(serverOptions.password)
    }

    func testExpandingPath() throws {
        let serverOptionsStr = "~/.config/"
        let expansion = "\(FileManager.default.homeDirectoryForCurrentUser.path)/.config/"
        XCTAssertEqual(expansion, serverOptionsStr.expandingTildeInPath())
    }

    func testContainsAny() throws {
        let options = ["Super", "Extra", "Wow"]
        XCTAssertTrue("Duper Super".containsAny(options))
        XCTAssertTrue("Extra Duper".containsAny(options))
        XCTAssertTrue("Wow wow".containsAny(options))
        XCTAssertFalse("wow wow".containsAny(options))
        XCTAssertFalse("XY extra wow".containsAny(options))
    }

    static var allTests = [
        ("testFullServerConfig", testFullServerConfig),
        ("testPartialConfig", testPartialConfig),
    ]
}
