import Foundation
import Combine
import Transmission
import GRDB

public struct TorrentRSS {
    var serverConfig: Config
    var feedOptions: [FeedOption]
    var store: Store

    public init(_ serverConfig: Config, _ feedOptions: [FeedOption]) {
        self.serverConfig = serverConfig
        self.feedOptions = feedOptions

        let databaseQueue = try! DatabaseQueue(path: serverConfig.db.expandingTildeInPath())
        self.store = Store(databaseQueue: databaseQueue)!
    }

    public func fetchAndUpdateDB() throws {

        print("[INFO] Updating DB - \(Date())")

        for feedOption in feedOptions {
            let rssXml = try! String(contentsOf: feedOption.link)
            guard let rss: RSS = RSS.decode(rss: rssXml) else {
                print("An error occurred while processing your feed")
                exit(1)
            }
            let feed = rss.channel

            let addedItems = try store.add(feed.items)
            let statuses = addedItems.map {
                TorrentItemStatus(
                    torrentItemId: $0.id!,
                    status: $0.title.containsAny(feedOption.include)
                        ? .added : .ignored,
                    date: Date())
            }
            try store.add(statuses)
        }

    }

    private func getTransmissionClient() -> Transmission? {
        let client = Transmission(
            baseURL: serverConfig.server,
            username: serverConfig.username,
            password: serverConfig.password)

        var cancellables = Set<AnyCancellable>()

        let group = DispatchGroup()
        group.enter()
        print("[INFO] Connecting to client")
        client.request(.rpcVersion)
            .sink(
                receiveCompletion: { _ in group.leave() },
                receiveValue: { rpcVersion in
                    print("[INFO]: Successfully Connected! RPC Version: \(rpcVersion)")
            })
            .store(in: &cancellables)
        let wallTimeout = DispatchWallTime.now() +
            DispatchTimeInterval.seconds(serverConfig.secondsTimeout ?? 15)
        let res = group.wait(wallTimeout: wallTimeout)

        for cancellable in cancellables {
            cancellable.cancel()
        }

        if res == DispatchTimeoutResult.success {
            return client
        } else {
            return nil
        }

    }

    public func initializeSeries() throws {
        try store.initializeSeries()
    }

    public func updatePendingDownload() throws {

        print("[INFO] [\(Date())] Starting Transmission Update")

        let clientOpt = getTransmissionClient()
        guard let client = clientOpt else {
            print("[ERROR] Failed to connect to transmission client")
            exit(1)
        }

        var cancellables = Set<AnyCancellable>()

        let items = try store.getPendingDownload()
        print("[INFO] [\(Date())] Adding \(items.count) new items to transmission")

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
                    do {
                        try self.store.update(item: item, with: .downloaded)

                    } catch {
                        print("[Error] Couldn't save new status to DB")
                    }
                })
                .store(in: &cancellables)
        }


        let wallTimeout = DispatchWallTime.now() +
            DispatchTimeInterval.seconds(serverConfig.secondsTimeout ?? 15)
        let res = group.wait(wallTimeout: wallTimeout)

        for cancellable in cancellables {
            cancellable.cancel()
        }

        if res == DispatchTimeoutResult.success {
            print("Tasks successfully submitted")
        } else {
            print("Timed out")
            exit(1)
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
