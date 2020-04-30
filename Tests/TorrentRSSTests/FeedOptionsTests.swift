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
    func testSingleFeedOptionDecoding() throws {
        let yamlFeedOption = """
        link: https://www.ataias.com.br
        include:
            - A
            - BC
            - K
        """
        let feedOptionOpt: FeedOption? = FeedOption(yaml: yamlFeedOption)
        let feedOption = try AssertNotNilAndUnwrap(feedOptionOpt)
        XCTAssertEqual("\(feedOption.link)", "https://www.ataias.com.br")
        XCTAssertEqual(feedOption.include, ["A", "BC", "K"])
    }

    func testMultiFeedOptionDecoding() throws {
        let yamlFeedOptions = """
        - link: https://www.ataias.com.br
          include:
            - A
            - BC
            - K
        - link: https://google.com
          include:
            - googlo
            - special
        """
        let feedOptionsOpt: [FeedOption]? = FeedOption.array(
            yaml: yamlFeedOptions)
        let feedOptions = try AssertNotNilAndUnwrap(feedOptionsOpt)
        XCTAssertEqual(feedOptions.count, 2)
        XCTAssertEqual("\(feedOptions[0].link)", "https://www.ataias.com.br")
        XCTAssertEqual(feedOptions[0].include, ["A", "BC", "K"])
        XCTAssertEqual("\(feedOptions[1].link)", "https://google.com")
        XCTAssertEqual(feedOptions[1].include, ["googlo", "special"])
    }


    static var allTests = [
        ("testMultiFeedOptionDecoding", testMultiFeedOptionDecoding),
    ]
}
