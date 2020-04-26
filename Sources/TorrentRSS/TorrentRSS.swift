import Foundation
import Combine
import Transmission

public struct TorrentRSS {
    var feedOptions: [FeedOption]

    public init(_ feedOptions: [FeedOption]) {
        self.feedOptions = feedOptions
    }

    public func run() {
        for feedOption in feedOptions {
            let rss = try! String(contentsOf: feedOption.link)
            let feedOpt = Feed(XMLString: rss)
            guard let feed = feedOpt else {
                print("An error occurred while processing your feed")
                exit(1)
            }
            let items = feed.items.filter {
                $0.title?.containsAny(feedOption.include) ?? false
            }
            for item in items {
                assert(item.title != nil, "Item in feed has empty title")
                assert(item.link != nil, "Item in feed does not have link")
                print("title: \(item.title!)")
                if let guid = item.guid?.value {
                    print("guid: \(guid)")
                }
                let linkComponents = item.link!.components(separatedBy: "&")
                assert(linkComponents.count > 0, "Link seems wrong")
                print("link [truncated]: \(linkComponents[0])")
                print()
            }
        }
    }
}

extension String {
    func containsAny<T>(_ others: [T]) -> Bool where T : StringProtocol {
        for other in others {
            if self.contains(other) {
                return true
            }
        }
        return false
    }
}
