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
            try setupDatabase(databaseQueue)
        } catch {
            return nil
        }

    }

    private func setupDatabase(_ db: DatabaseWriter) throws {
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

        try self.addSeries(items)
        print("[Store] [\(Date())] Successfully added series")

        return added

    }

    private func addSeries(_ items: [TorrentItem]) throws {
        try databaseQueue.write { db in
            for item in items {
                let seriesInDb: Series? =
                    try Series
                        .filter(Column("name") == item.seriesMetadata!.name)
                        .fetchOne(db)
                if seriesInDb == nil {
                    try Series(name: item.seriesMetadata!.name).insert(db)
                }
            }
        }
    }

    public func initializeSeries() throws {
        var itemsToAdd: [TorrentItem]? = nil

        try databaseQueue.read { db in
            let dbItems = try Series
              .order(Column("id"))
              .fetchAll(db)
            if dbItems.count == 0 {
              itemsToAdd = try TorrentItem.fetchAll(db)
            }
        }

        if let items = itemsToAdd {
            try self.addSeries(items)
        }
    }

    func add(_ statuses: [TorrentItemStatus]) throws {
        try databaseQueue.write { db in
            try statuses.forEach { try $0.insert(db) }
        }
    }

    func filterTorrentItems(by: FileStatus) throws -> [TorrentItem] {
        try databaseQueue.write { db in
            let sql = """
            SELECT * FROM torrentItem WHERE id IN (
                SELECT torrentItemId from (
                    SELECT torrentItemStatus.*, max(date) AS date
                    FROM torrentItemStatus
                    GROUP BY torrentItemId
                    HAVING status = "\(by.rawValue)"
                )
            )
            """
            let items = try TorrentItem
                .fetchAll(db, sql: sql)

            return items
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
