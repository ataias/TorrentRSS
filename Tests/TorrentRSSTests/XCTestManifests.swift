import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(TorrentRSSTests.allTests),
        testCase(FeedTests.allTests),
    ]
}
#endif
