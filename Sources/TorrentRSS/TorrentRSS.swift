import Foundation
import Combine
import Transmission

public struct TorrentRSS {
    var serverConfig: Config
    var feedOptions: [FeedOption]

    public init(_ serverConfig: Config, _ feedOptions: [FeedOption]) {
        self.serverConfig = serverConfig
        self.feedOptions = feedOptions
    }

    public func run() {

        print("[INFO] \(Date())")
        let client = Transmission(
            baseURL: serverConfig.server,
            username: serverConfig.username,
            password: serverConfig.password)

        var cancellables = Set<AnyCancellable>()

        for feedOption in feedOptions {
            let rssXml = try! String(contentsOf: feedOption.link)
            guard let rss: RSS = RSS.decode(rss: rssXml) else {
                print("An error occurred while processing your feed")
                exit(1)
            }
            let feed = rss.channel
            let items = feed.items.filter {
                $0.title.containsAny(feedOption.include)
            }

            // TODO Store items in database
            // Should send whole feed.items
            // feed.items that do not satisfy filter are added as ignored

            // TODO Read items in database that need to be downloaded
            // TODO change "items" below by the items read from the database
            let group = DispatchGroup()
            for item in items {

                let linkComponents = "\(item.link)".components(separatedBy: "&")
                assert(linkComponents.count > 0, "Link seems wrong")

                group.enter()
                client.request(.add(url: item.link))
                    .sink(receiveCompletion: { completion in
                        if case let .failure(error) = completion {
                            print("[Failure] \(item.title)")
                            print("[Failure] Details: \(error)")

                        }
                        group.leave()
                    }, receiveValue: { _ in
                        print("[Success] \(item.title)")
                    })
                    .store(in: &cancellables)
            }


            let wallTimeout = DispatchWallTime.now() +
                DispatchTimeInterval.seconds(serverConfig.secondsTimeout ?? 15)
            let res = group.wait(wallTimeout: wallTimeout)
            if res == DispatchTimeoutResult.success {
                print("Tasks successfully submitted")
            } else {
                print("Timed out")
                exit(1)
            }
        }
    }
}

public extension String {
    func containsAny<T>(_ others: [T]) -> Bool where T : StringProtocol {
        for other in others {
            if self.contains(other) {
                return true
            }
        }
        return false
    }

    func expandingTildeInPath() -> String {
        return self.replacingOccurrences(of: "~", with: FileManager.default.homeDirectoryForCurrentUser.path)
    }

}
