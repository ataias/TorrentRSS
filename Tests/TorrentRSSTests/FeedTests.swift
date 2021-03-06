//
//  File.swift
//
//
//  Created by Ataias Pereira Reis on 23/04/20.
//

import Foundation
import XCTest
@testable import TorrentRSS

final class FeedTests: XCTestCase {
    func testSingleTorrentItem() {
        let singleItem = """
        <item>
        <title>[PREFIX] Filename - 1.something</title>
        <link>magnet:?xt=urn:btih:RANDOMCODEHERE1&amp;\
        tr=http://ataias-tracker.br:7777/announce</link>
        <guid isPermaLink="false">RANDOMCODEHERE1</guid>
        <pubDate>Wed, 22 Apr 2020 14:34:48 +0000</pubDate>
        </item>
        """
        let torrentItem: TorrentItem = RSS.decode(rss: singleItem)!
        XCTAssertEqual(torrentItem.title, "[PREFIX] Filename - 1.something")
        XCTAssertEqual(torrentItem.seriesMetadata!.name, "Filename")

        let dateFormatter = TorrentItem.dateFormatter
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        XCTAssertEqual(
            dateFormatter.string(from: torrentItem.pubDate),
            "Wed, 22 Apr 2020 14:34:48 +0000")
        XCTAssertEqual(torrentItem.guid.value, "RANDOMCODEHERE1")
    }

    func testGuid() {
            let singleItem = """
            <guid isPermaLink="false">RANDOMCODEHERE1</guid>
            """
            let guid: Guid = RSS.decode(rss: singleItem)!
            XCTAssertEqual(guid.value, "RANDOMCODEHERE1")
            XCTAssertFalse(guid.isPermaLink)
        }

    func testSingleTorrentItemPartial() {
        // Link is missing, we will fail in this case
        let singleItem = """
        <item>
        <title>Filename 1.something</title>
        <guid isPermaLink="false">RANDOMCODEHERE1</guid>
        <pubDate>Wed, 22 Apr 2020 14:34:48 +0000</pubDate>
        </item>
        """
        let torrentItem: TorrentItem? = RSS.decode(rss: singleItem)
        XCTAssertNil(torrentItem)
    }

    func testFeed() {
        let rssFeed = """
        <rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
        <channel>
        <title>RSS Title</title>
        <description>A description of this feed</description>
        <link>http://www.ataias.com.br</link>
        <item>
        <title>[PA] Fil-, ename A - 1 [1080p].something</title>
        <link>magnet:?xt=urn:btih:RANDOMCODEHERE1&amp;\
        tr=http://ataias-tracker.br:7777/announce</link>
        <guid isPermaLink="false">RANDOMCODEHERE1</guid>
        <pubDate>Wed, 22 Apr 2020 14:34:48 +0000</pubDate>
        </item>
        <item>
        <title>[PA] Filename - 2.something</title>
        <link>magnet:?xt=urn:btih:RANDOMCODEHERE2&amp;\
        tr=http://ataias-tracker.br:7777/announce</link>
        <guid isPermaLink="false">RANDOMCODEHERE2</guid>
        <pubDate>Tue, 21 Apr 2020 14:34:48 +0000</pubDate>
        </item>
        <item>
        <title>[PA] Filename - 3.something</title>
        <link>magnet:?xt=urn:btih:RANDOMCODEHERE3&amp;\
        tr=http://ataias-tracker.br:7777/announce</link>
        <guid isPermaLink="false">RANDOMCODEHERE3</guid>
        <pubDate>Wed, 20 Apr 2020 14:34:48 +0000</pubDate>
        </item>
        </channel>
        </rss>
        """

        let rss: RSS = RSS.decode(rss: rssFeed)!
        let feed = rss.channel
        XCTAssertEqual(feed.title, "RSS Title")
        XCTAssertEqual(feed.description, "A description of this feed")
        XCTAssertEqual("\(feed.link)", "http://www.ataias.com.br")
        XCTAssertEqual(feed.items.count, 3)
        XCTAssertEqual(
            feed.items[0].title,
            "[PA] Fil-, ename A - 1 [1080p].something")
        XCTAssertEqual(feed.items[0].seriesMetadata!.name, "Fil-, ename A")
        XCTAssertEqual(feed.items[0].seriesMetadata!.episode, 1)
        XCTAssertEqual(feed.items[0].guid.value, "RANDOMCODEHERE1")

        XCTAssertEqual(feed.items[1].seriesMetadata!.episode, 2)
    }


    static var allTests = [
        ("testSingleTorrentItem", testSingleTorrentItem),
        ("testGuid", testGuid),
        ("testSingleTorrentItemPartial", testSingleTorrentItemPartial),
        ("testFeed", testFeed),

    ]
}
