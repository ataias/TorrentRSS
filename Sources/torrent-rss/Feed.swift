//
//  File.swift
//  
//
//  Created by Ataias Pereira Reis on 23/04/20.
//

import Foundation
import XMLMapper

//<item>
//<title>Filename 1.something</title>
//<link>magnet:?xt=urn:btih:RANDOMCODEHERE1&amp;\
//tr=http://ataias-tracker.br:7777/announce</link>
//<guid isPermaLink="false">RANDOMCODEHERE1</guid>
//<pubDate>Wed, 22 Apr 2020 14:34:48 +0000</pubDate>
//</item>

struct Guid: XMLMappable {
    var nodeName: String!

    var value: String?
    var isPermalink: Bool?

    init?(map: XMLMap) { }

    mutating func mapping(map: XMLMap) {
        value <- map.innerText
        isPermalink <- map.attributes["isPermalink"]
    }
}
struct TorrentItem: XMLMappable {
    var nodeName: String!

    var title: String?
    var link: String?
    var guid: Guid!
    var pubDate: Date?

    init?(map: XMLMap) {
        for el in ["title", "link", "guid", "pubDate"] {
            if map.XML[el] == nil {
                return nil
            }
        }
    }

    mutating func mapping(map: XMLMap) {
        title <- map["title"]
        link <- map["link"]
        guid <- map["guid"]
        pubDate <- map["pubDate"]
    }
}

struct Feed: XMLMappable {
    var nodeName: String!

    var title: String?
    var description: String?
    var link: String?
    var items: [TorrentItem]?

    init?(map: XMLMap) {
        // in our struct, we use "items", but the XML data has simply a
        // bunch of "item" elements, without an enclosing "items"
        // so we just check for the "item" existence below
        for el in ["channel.title", "channel.description", "channel.link", "channel.item"] {
            if !map[el].isKeyPresent {
                return nil
            }
        }
    }

    mutating func mapping(map: XMLMap) {
        title <- map["channel.title"]
        description <- map["channel.description"]
        link <- map["channel.link"]
        items <- map["channel.item"]
    }
}
