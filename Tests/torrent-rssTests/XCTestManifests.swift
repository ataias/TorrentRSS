import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(torrent_rssTests.allTests),
    ]
}
#endif
