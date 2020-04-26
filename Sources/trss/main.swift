//
//  File.swift
//
//
//  Created by Ataias Pereira Reis on 26/04/20.
//

import Foundation
import TorrentRSS

let args = CommandLine.arguments
if args.count != 2 {
    print("Usage: trss config-file.yaml")
} else {
    let file = args[1]
    print("Given file: \(file)")
    let feedOptionsStr = try! String(contentsOfFile: file)
    let feedOptions = FeedOption.array(yaml: feedOptionsStr)
    assert(feedOptions != nil, "Feed is nil")
    let torrentRSSFeed = TorrentRSS(feedOptions!)
    torrentRSSFeed.run()
    print(feedOptions ?? "error")
}
