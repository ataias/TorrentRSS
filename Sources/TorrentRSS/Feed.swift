//
//  File.swift
//
//
//  Created by Ataias Pereira Reis on 23/04/20.
//

import Foundation
import XMLMapper


public struct Feed: XMLMappable {
    public var nodeName: String!

    var title: String!
    var description: String!
    var link: String!
    var items: [TorrentItem]!

    public init?(map: XMLMap) {
        // in our struct, we use "items", but the XML data has simply a
        // bunch of "item" elements, without an enclosing "items"
        // so we just check for the "item" existence below
        for el in [
            "channel.title",
            "channel.description",
            "channel.link",
            "channel.item"] {
            if !map[el].isKeyPresent {
                return nil
            }
        }
    }

    public mutating func mapping(map: XMLMap) {
        title <- map["channel.title"]
        description <- map["channel.description"]
        link <- map["channel.link"]
        items <- map["channel.item"]
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


    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        return formatter
    }

    mutating func mapping(map: XMLMap) {
        title <- map["title"]
        link <- map["link"]
        guid <- map["guid"]
        pubDate <- (map["pubDate"],
                    XMLDateFormatterTransform(
                        dateFormatter: TorrentItem.dateFormatter))
    }
}

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
