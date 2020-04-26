//
//  File.swift
//
//
//  Created by Ataias Pereira Reis on 26/04/20.
//

import Foundation
import XCTest
@testable import TorrentRSS

let yamlFeedOptions = """
link: https://www.ataias.com.br
include:
    - A
    - BC
    - K
"""

struct NilUnwrappingError: Error {}

func AssertNotNilAndUnwrap<T>(_ variable: T?, message: String = "Unexpected nil variable", file: StaticString = #file, line: UInt = #line) throws -> T {
    guard let variable = variable else {
        XCTFail(message, file: file, line: line)
        throw NilUnwrappingError()
    }
    return variable
}

final class FeedOptionsTests: XCTestCase {
    func testFeedOptionsDecoding() throws {
        let yamlFeedOptions = """
        link: https://www.ataias.com.br
        include:
            - A
            - BC
            - K
        """
        let feedOptionsOpt: FeedOptions? = FeedOptions(yaml: yamlFeedOptions)
        let feedOptions = try AssertNotNilAndUnwrap(feedOptionsOpt)
        XCTAssertEqual("\(feedOptions.link)", "https://www.ataias.com.br")
        XCTAssertEqual(feedOptions.include, ["A", "BC", "K"])
    }

    static var allTests = [
        ("testFeedOptionsDecoding", testFeedOptionsDecoding),
    ]
}
