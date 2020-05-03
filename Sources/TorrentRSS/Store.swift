//
//  File.swift
//
//
//  Created by Ataias Pereira Reis on 28/04/20.
//

import Foundation
import GRDB

public struct Store {
    var databaseQueue: DatabaseQueue

    init?(databaseQueue: DatabaseQueue) {
        self.databaseQueue = databaseQueue
        do {
            try createTables(databaseQueue)
        } catch {
            return nil
        }

    }

    private func createTables(_ db: DatabaseWriter) throws {
        let migrator = getMigrations()
        try migrator.migrate(db)
    }

    func add(_ items: [TorrentItem]) throws -> [TorrentItem] {

        var added: [TorrentItem] = []

        try databaseQueue.write { db in

            for var item in items {
                let itemInDb: TorrentItem? =
                    try TorrentItem
                        .filter(Column("title") == item.title)
                        .fetchOne(db)
                if itemInDb == nil {
                    try item.insert(db)
                    added.append(item)
                    print("[Store] Added item \(item.id ?? 0) to db")
                }
            }
        }
        print("[Store] [\(Date())] \(added.count) items added to database")
        return added

    }

    private func addSeries(_ items: [TorrentItem]) throws {
        try databaseQueue.write { db in
            for item in items {
                let seriesInDb: Series? =
                try Series
                    .filter(Column("name") == item.series)
                    .fetchOne(db)
                if seriesInDb == nil {
                    try Series(name: item.series).insert(db)
                }
            }
        }
    }

    func add(_ statuses: [TorrentItemStatus]) throws {
        try databaseQueue.write { db in
            for status in statuses {
                try status.insert(db)
            }
        }
    }

    func filterTorrentItems(by: FileStatus) throws -> [TorrentItem] {
        try databaseQueue.write { db in
            let sql = """
            SELECT torrentItemStatus.*, max(date) AS date
            FROM torrentItemStatus
            GROUP BY torrentItemId
            """
            let statuses = try TorrentItemStatus
                .fetchAll(db, sql: sql)
                .filter { $0.status == by }

            return try statuses.map { try $0.torrentItem.fetchOne(db)! }
        }
    }

    func getPendingDownload() throws -> [TorrentItem] {
        return try filterTorrentItems(by: .added)
    }

    func update(item: TorrentItem, with: FileStatus) throws {
        try databaseQueue.write { db in
            let newStatus = TorrentItemStatus(
                torrentItemId: item.id!,
                status: with,
                date: Date())

            try newStatus.insert(db)
            print("[Success] Update item \(item.id!) with status \(with)")
        }
    }
}
