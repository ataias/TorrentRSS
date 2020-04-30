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

    private func createTables(_ db: DatabaseWriter) throws {
        let migrator = getMigrations()
        try migrator.migrate(db)
    }

    func addTorrents(_ items: [TorrentItem]) throws {
        try createTables(databaseQueue)
        try databaseQueue.write { db in

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
