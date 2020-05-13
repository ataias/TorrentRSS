//
//  File.swift
//
//
//  Created by Ataias Pereira Reis on 26/04/20.
//

import Foundation
import TorrentRSS

let args = CommandLine.arguments
if args.count != 3 {
    print("Usage: trss server.yaml feed.yaml")
} else {
    let serverFile = args[1].expandingTildeInPath()
    let feedFile = args[2].expandingTildeInPath()

    let serverOptionsStr = try? String(contentsOfFile: serverFile)
    guard serverOptionsStr != nil else {
        print("Error reading server file \(serverFile)")
        exit(1)
    }
    let feedOptionsStr = try? String(contentsOfFile: feedFile)
    guard feedOptionsStr != nil else {
        print("Error reading feed file \(feedFile)")
        exit(1)
    }

    let serverOptions = Config(yaml: serverOptionsStr!)
    let feedOptions = FeedOption.array(yaml: feedOptionsStr!)

    assert(serverOptions != nil, "Server config is nil")
    assert(feedOptions != nil, "Feed is nil")

    let torrentRSSFeed = TorrentRSS(serverOptions!, feedOptions!)
    try torrentRSSFeed.fetchAndUpdateDB()
    try torrentRSSFeed.updatePendingDownload()
}
