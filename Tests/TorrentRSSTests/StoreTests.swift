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

    func generate(items n: Int64) -> [TorrentItem] {
        let items: [TorrentItem] = (1...n).map {
            TorrentItem (
//                id: $0,
                title: "Title \($0).mkv",
                link: URL(string: "http://server.com/title\($0).mkv")!,
                guid: Guid(value: "GUID_\($0)", isPermaLink: false),
                pubDate: Calendar.current.date(byAdding: .day,
                                               value: Int(n - $0),
                                               to: Date())!
            )
        }
        return items
    }

    func testAddItems() throws {
        let n = 4
        let items = generate(items: 4)
        let dbQueue = DatabaseQueue()

        let store = Store(databaseQueue: dbQueue)!
        let addedItems = try store.add(items)
        XCTAssertEqual(addedItems.count, n)
        XCTAssertEqual(addedItems[0].id, 1)

        let noItems = try store.add(items)
        XCTAssertEqual(noItems.count, 0)

        try dbQueue.read { db in
            let dbItems = try TorrentItem
                .order(Column("id"))
                .fetchAll(db)
            XCTAssertEqual(dbItems.count, n)
            XCTAssertEqual(dbItems[0].id, 1)
        }
    }

    func generate(_ n: Int64, with: FileStatus) -> [TorrentItemStatus] {
        let statuses: [TorrentItemStatus] = (1...n).map {
            TorrentItemStatus (
                torrentItemId: $0,
                status: with,
                date: Calendar.current.date(byAdding: .day,
                                            value: Int(n - $0),
                                            to: Date())!
            )
        }
        return statuses
    }

    func testAddStatuses() throws {
        let n: Int64 = 4
        let items = generate(items: n)
        let dbQueue = DatabaseQueue()

        let store = Store(databaseQueue: dbQueue)!
        XCTAssertNoThrow(try store.add(items))

        XCTAssertNoThrow(try store.add(generate(n, with: .added)))
        XCTAssertNoThrow(try store.add(generate(n, with: .downloaded)))
        XCTAssertNoThrow(try store.add(generate(n, with: .ignored)))
        XCTAssertNoThrow(try store.add(generate(n, with: .deleted)))

        // Test number of records and association from status to item
        try dbQueue.read { db in
            let dbItems = try TorrentItemStatus.fetchAll(db)
            XCTAssertEqual(dbItems.count, Int(n) * 4)

            XCTAssertEqual(try dbItems[0].torrentItem.fetchOne(db)!.id, 1)
        }

        // Test association from item to statuses
        try dbQueue.read { db in
            let dbItems = try TorrentItem.fetchAll(db)
            XCTAssertEqual(dbItems.count, Int(n))
            XCTAssertEqual(
                try dbItems[0].torrentItemStatuses.fetchAll(db).count, 4)
        }

        // TODO Move these calls to the main code and then call it here
        // TODO Avoid calling dbQueue here, use Store for that
        try dbQueue.read { db in
            let dbItems = try TorrentItemStatus
                .filter(Column("status") == FileStatus.downloaded.rawValue)
                .fetchAll(db)
            XCTAssertEqual(dbItems.count, Int(n))
            XCTAssert(dbItems[0].status == FileStatus.downloaded)
        }

    }


    static var allTests = [
        ("testAddItems", testAddItems),
        ("testAddStatuses", testAddStatuses),
    ]
}
