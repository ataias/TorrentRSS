//
//  File.swift
//
//
//  Created by Ataias Pereira Reis on 23/04/20.
//

import Foundation
import XMLCoder
import GRDB

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


struct TorrentItem: Codable, TableRecord, FetchableRecord {

    static let torrentItemStatuses = hasMany(TorrentItemStatus.self)

    var id: Int64?
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

    var torrentItemStatuses: QueryInterfaceRequest<TorrentItemStatus> {
        return request(for: TorrentItem.torrentItemStatuses)
    }

    var seriesMetadata: SeriesMetadata? {
        let pattern = "^\\[.*\\]\\s+(?<series>.+)\\s+-\\s+(?<episode>\\d+)"
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)

        guard let match = regex?.firstMatch(in: title, options: [], range: NSRange(location: 0, length: title.utf16.count)) else {
            return nil
        }

        let seriesRange = Range(match.range(withName: "series"), in: title)!
        let seriesName = String(title[seriesRange])

        let episodeRange = Range(match.range(withName: "episode"), in: title)!
        let episodeNumber = Int(String(title[episodeRange]))!


        return SeriesMetadata(name: seriesName, episode: episodeNumber)
    }
}

struct SeriesMetadata {
    var name: String
    var episode: Int
}

extension TorrentItem: MutablePersistableRecord {
    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
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

struct TorrentItemStatus: Codable, TableRecord, FetchableRecord, PersistableRecord {

    static let torrentItem = belongsTo(TorrentItem.self)
    static let series = belongsTo(Series.self)

    var id: Int64?
    var torrentItemId: Int64
    var status: FileStatus
    var date: Date

    var torrentItem: QueryInterfaceRequest<TorrentItem> {
        return request(for: TorrentItemStatus.torrentItem)
    }

    var series: QueryInterfaceRequest<Series> {
        return request(for: TorrentItemStatus.series)
    }
}

enum FileStatus: String, Codable {
    /// Item is added and should be downloaded
    case added

    /// Item info is stored, but no further action
    case ignored

    /// Item already in torrent program
    case downloaded

    /// Item previously downloaded, but deleted
    case deleted
}

struct Series: Codable, TableRecord, FetchableRecord, PersistableRecord {
    var id: Int?
    var name: String
}

struct Episode: Codable, TableRecord, FetchableRecord, PersistableRecord {
    var id: Int64?
    var seriesId: Int
    var torrentItemId: Int64
    var episode: Int
    var watchStatus: WatchStatus
}

enum WatchStatus: String, Codable {
    case pending
    case ignored
    case watched
}

enum TRSSError: Error {
    case noId
}
