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


struct TorrentItem: XMLMappable {
    var nodeName: String!

    var title: String?
    var link: String?
    var guid: String?
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
