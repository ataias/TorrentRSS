import Foundation

public struct TorrentRSS {
    var feedOptions: [FeedOption]


    func run() {
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
            print(items)
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
