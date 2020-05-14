//
//  File.swift
//
//
//  Created by Ataias Pereira Reis on 30/04/20.
//

import Foundation
import GRDB
func getMigrations() -> DatabaseMigrator {
    var migrator = DatabaseMigrator()

    migrator.registerMigration("v1") { db in
        try db.create(table: "torrentItem", ifNotExists: true) { t in
            t.autoIncrementedPrimaryKey("id")
            t.column("title", .text).notNull().unique()
            t.column("link", .text).notNull()
            t.column("guid", .text).notNull()
            t.column("pubDate", .datetime).notNull()
        }

        try db.create(table: "series", ifNotExists: true) { t in
            t.autoIncrementedPrimaryKey("id")
            t.column("name", .text).notNull()
        }

        // TODO Add method to automatically add episodes based on torrent item
        try db.create(table: "episodes", ifNotExists: true) { t in
            t.autoIncrementedPrimaryKey("id")
            t.column("seriesId", .integer)
                .notNull()
                .indexed()
                .references("series", onDelete: .restrict)
            t.column("torrentItemId", .integer)
                .notNull()
                .indexed()
                .references("torrentItem", onDelete: .restrict)
            t.column("episode", .integer)
                .notNull()
            t.column("watchStatus", .integer)
                .notNull()

        }

        try db.create(table: "torrentItemStatus", ifNotExists: true) { t in
            t.autoIncrementedPrimaryKey("id")
            t.column("torrentItemId", .integer)
                .notNull()
                .indexed()
                .references("torrentItem", onDelete: .restrict)
            t.column("status", .text).notNull()
            t.column("date", .datetime).notNull()
        }
    }

    return migrator;
}
