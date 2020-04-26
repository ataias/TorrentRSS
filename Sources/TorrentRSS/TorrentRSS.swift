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
        let client = Transmission(
            baseURL: serverConfig.server,
            username: serverConfig.username,
            password: serverConfig.password)

        var cancellables = Set<AnyCancellable>()

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

            let group = DispatchGroup()
            for item in items {
                assert(item.title != nil, "Item in feed has empty title")
                assert(item.link != nil, "Item in feed does not have link")

                let linkComponents = "\(item.link!)".components(separatedBy: "&")
                assert(linkComponents.count > 0, "Link seems wrong")

                group.enter()
                client.request(.add(url: item.link!))
                    .sink(receiveCompletion: { completion in
                        if case let .failure(error) = completion {
                            print("[Failure] \(item.title!)")
                            print("[Failure] Details: \(error)")

                        }
                        group.leave()
                    }, receiveValue: { _ in
                        print("[Success] \(item.title!)")
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
