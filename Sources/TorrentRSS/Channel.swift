//
//  File.swift
//
//
//  Created by Ataias Pereira Reis on 23/04/20.
//

import Foundation
import XMLCoder

public struct RSS: Codable {
    var channel: Channel

    static func decode<T: Codable>(rss: String) -> T? {
        let decoder = XMLDecoder()
        decoder.dateDecodingStrategy = .formatted(TorrentItem.dateFormatter)
        guard let data = rss.data(using: .utf8) else { return nil }
        return try? decoder.decode(T.self, from: data)
    }
}

public struct Channel: Codable, DynamicNodeDecoding {

    var title: String
    var description: String
    var link: URL
    var items: [TorrentItem]

    enum CodingKeys: String, CodingKey {
        case title
        case description
        case link
        case items = "item"
    }

    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
        default: return .element
        }
    }
}


struct TorrentItem: Codable {

    var title: String
    var link: URL
    var guid: Guid
    var pubDate: Date

    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        return formatter
    }
}

struct Guid: Codable, DynamicNodeDecoding {

    var value: String
    var isPermaLink: Bool

    enum CodingKeys: String, CodingKey {
        case value = ""
        case isPermaLink
    }

    static func nodeDecoding(for key: CodingKey)
        -> XMLDecoder.NodeDecoding {
            switch key {
            case CodingKeys.isPermaLink:
                return .attribute
            default:
                return .element
            }
    }

}
