//
//  File.swift
//
//
//  Created by Ataias Pereira Reis on 28/04/20.
//

import Foundation
import XCTest
import GRDB
@testable import TorrentRSS

final class StoreTests: XCTestCase {
    func testAddItems() throws {
        let n = 4
        let items: [TorrentItem] = (1...n).map {
            TorrentItem (
                title: "Title \($0).mkv",
                link: URL(string: "http://server.com/title\($0).mkv")!,
                guid: Guid(value: "GUID_\($0)", isPermaLink: false),
                pubDate: Date()
            )
        }

        let dbQueue = DatabaseQueue()
        let store = Store(databaseQueue: dbQueue)
        XCTAssertNoThrow(try store.addTorrents(items))
        XCTAssertNoThrow(try store.addTorrents(items))

        try dbQueue.read { db in
            let dbItems = try TorrentItem.fetchAll(db)
            XCTAssertEqual(dbItems.count, n)
            for item in dbItems {
                print("ID: \(item.id!)")
            }
        }
    }


    static var allTests = [
        ("testAddItems", testAddItems),
    ]
}
