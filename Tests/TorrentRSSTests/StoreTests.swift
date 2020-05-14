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

        try dbQueue.read { db in
            let dbItems = try Series
              .order(Column("id"))
              .fetchAll(db)
            // All start by "Title", so that's the only series
            XCTAssertEqual(dbItems.count, 1)
            XCTAssertEqual(dbItems[0].id, 1)
            XCTAssertEqual(dbItems[0].name, "Title")
        }
    }

    func generate(items n: Int64, series: String = "Title") -> [TorrentItem] {
        let items: [TorrentItem] = (1...n).map {
            TorrentItem (
              title: "[prefix suffix] \(series) - \($0).mkv",
              link: URL(string: "http://server.com/title\($0).mkv")!,
              guid: Guid(value: "GUID_\($0)", isPermaLink: false),
              pubDate: Calendar.current.date(byAdding: .day,
                                             value: Int(n - $0),
                                             to: Date())!
            )
        }
        return items
    }

    func testInitializeSeries() throws {
        let items =
          generate(items: 5, series: "Another Title") +
          generate(items: 3, series: "Even Another Title") +
          generate(items: 2, series: "Sweet") +
          generate(items: 1, series: "Sweet and Sour")

        let dbQueue = DatabaseQueue()

        let store = Store(databaseQueue: dbQueue)!
        try dbQueue.write { db in
            for var item in items {
              try item.insert(db);
            }
        }

        try dbQueue.read { db in
            let dbItems = try TorrentItem
              .fetchAll(db)
            XCTAssertEqual(dbItems.count, items.count)
        }

        try dbQueue.read { db in
            let dbItems = try Series
              .fetchAll(db)
            // we haven't initialized yet
            XCTAssertEqual(dbItems.count, 0)
        }

        try store.initializeSeries()

        try dbQueue.read { db in
            let series = try Series
              .order(Column("id"))
              .fetchAll(db)
            // we have added only 4 types of series
            XCTAssertEqual(series.count, 4)
            XCTAssertEqual(series[0].name, "Another Title")
            XCTAssertEqual(series[1].name, "Even Another Title")
            XCTAssertEqual(series[2].name, "Sweet")
            XCTAssertEqual(series[3].name, "Sweet and Sour")
        }
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

        try dbQueue.read { db in
            let dbItems = try TorrentItemStatus
                .filter(Column("status") == FileStatus.downloaded.rawValue)
                .fetchAll(db)
            XCTAssertEqual(dbItems.count, Int(n))
            XCTAssert(dbItems[0].status == FileStatus.downloaded)
        }

    }

    func generate(_ n: Int64, with: FileStatus, dateOffset: Int = 0) -> [TorrentItemStatus] {
        let statuses: [TorrentItemStatus] = (1...n).map {
            TorrentItemStatus (
              torrentItemId: $0,
              status: with,
              date: Calendar.current.date(byAdding: .day,
                                          value: Int(n - $0) + dateOffset,
                                          to: Date())!
            )
        }
        return statuses
    }


    func testFilterByLastStatus() throws {
        let n: Int64 = 4
        let items = generate(items: n * 2)
        let dbQueue = DatabaseQueue()

        let store = Store(databaseQueue: dbQueue)!
        let _ = try store.add(items)

        try store.add(generate(n * 2, with: .added))
        try store.add(generate(n, with: .downloaded, dateOffset: 4))

        let latestDownloaded = try store.filterTorrentItems(by: .downloaded)

        XCTAssertEqual(latestDownloaded.count, Int(n))
        XCTAssertEqual(latestDownloaded.map({$0.id!}).sorted(), Array(1...n))
    }

    static var allTests = [
        ("testAddItems", testAddItems),
        ("testAddStatuses", testAddStatuses),
        ("testFilterByLastStatus", testFilterByLastStatus)
    ]
}
