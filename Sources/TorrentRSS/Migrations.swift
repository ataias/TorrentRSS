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
            t.column("title", .text).notNull()
            t.column("link", .text).notNull()
            t.column("guid", .text).notNull()
            t.column("pubDate", .datetime).notNull()
        }
    }

    return migrator;
}
