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

    func generate(items n: Int) -> [TorrentItem] {
        let items: [TorrentItem] = (1...n).map {
            TorrentItem (
                id: $0,
                title: "Title \($0).mkv",
                link: URL(string: "http://server.com/title\($0).mkv")!,
                guid: Guid(value: "GUID_\($0)", isPermaLink: false),
                pubDate: Calendar.current.date(byAdding: .day,
                                               value: n - $0,
                                               to: Date())!
            )
        }
        return items
    }

    func testAddItems() throws {
        let n = 4
        let items = generate(items: 4)
        let dbQueue = DatabaseQueue()

        let store = Store(databaseQueue: dbQueue)
        XCTAssertNoThrow(try store.add(items))
        XCTAssertNoThrow(try store.add(items))

        try dbQueue.read { db in
            let dbItems = try TorrentItem.fetchAll(db)
            XCTAssertEqual(dbItems.count, n)
            for item in dbItems {
                print("ID: \(item.id!)")
            }
        }
    }

    func generate(_ n: Int, with: Status) -> [TorrentItemStatus] {
        let statuses: [TorrentItemStatus] = (1...n).map {
            TorrentItemStatus (
                torrentItemId: $0,
                status: with,
                date: Calendar.current.date(byAdding: .day,
                                            value: n - $0,
                                            to: Date())!
            )
        }
        return statuses
    }

    func testAddStatuses() throws {
        let n = 4
        let items = generate(items: n)
        let dbQueue = DatabaseQueue()

        let store = Store(databaseQueue: dbQueue)
        XCTAssertNoThrow(try store.add(items))

        XCTAssertNoThrow(try store.add(generate(n, with: .added)))
        XCTAssertNoThrow(try store.add(generate(n, with: .downloaded)))
        XCTAssertNoThrow(try store.add(generate(n, with: .ignored)))

        // Test number of records and association from status to item
        try dbQueue.read { db in
            let dbItems = try TorrentItemStatus.fetchAll(db)
            XCTAssertEqual(dbItems.count, n * 3)

            XCTAssertEqual(try dbItems[0].torrentItem.fetchOne(db)!.id, 1)
        }

        // Test association from item to statuses
        try dbQueue.read { db in
            let dbItems = try TorrentItem.fetchAll(db)
            XCTAssertEqual(dbItems.count, n)
            XCTAssertEqual(
                try dbItems[0].torrentItemStatuses.fetchAll(db).count, 3)
        }

        // TODO Test getting items with latest status downloaded

    }


    static var allTests = [
        ("testAddItems", testAddItems),
        ("testAddStatuses", testAddStatuses),
    ]
}
