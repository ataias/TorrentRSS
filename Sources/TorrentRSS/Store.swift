//
//  File.swift
//
//
//  Created by Ataias Pereira Reis on 28/04/20.
//

import Foundation
import GRDB

struct Store {
    var databaseQueue: DatabaseQueue

    private func createTables(_ db: Database) throws {
        try db.create(table: "torrentItem", ifNotExists: true) { t in
            t.autoIncrementedPrimaryKey("id")
            t.column("title", .text).notNull()
            t.column("link", .text).notNull()
            t.column("guid", .text).notNull()
            t.column("pubDate", .datetime).notNull()
        }
    }

    func addTorrents(_ items: [TorrentItem]) throws {
        try databaseQueue.write { db in
            try createTables(db)

            for item in items {
                let itemInDb: TorrentItem? =
                    try TorrentItem
                        .filter(Column("title") == item.title)
                        .fetchOne(db)
                if let itemInDb = itemInDb {
                    print("[Store] Item \(itemInDb.title) already in db")
                } else {
                    try item.insert(db)
                    print("[Store] Added item \(item.id ?? 0) to db")
                }
            }
        }

    }
}
