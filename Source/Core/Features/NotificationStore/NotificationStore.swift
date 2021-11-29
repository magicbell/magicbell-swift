//
//  NotificationStore.swift
//  MagicBell
//
//  Created by Javi on 28/11/21.
//

import Harmony

protocol NotificationStoreDelegate: AnyObject {
    func pageForStore(_ store: NotificationStore, name: String, cursor: CursorPredicate) -> Future<StorePage>
}

public class NotificationStore {

    private let defaultNumberNotification = 20

    public let name: String
    public let storePredicate: StorePredicate
    public var edges: [Edge<Notification>] = []
    public private(set) var totalCount: Int = 0
    public private(set) var unreadCount: Int = 0
    public private(set) var unseenCount: Int = 0

    private(set) weak var delegate: NotificationStoreDelegate?
    private let logger: Logger

    private var nextPageCursor: String?
    public private(set) var hasNextPage = true

    init(name: String,
         storePredicate: StorePredicate,
         delegate: NotificationStoreDelegate,
         logger: Logger) {
        self.name = name
        self.storePredicate = storePredicate
        self.delegate = delegate
        self.logger = logger
    }

    public func fetch(completion: @escaping (Result<[Notification], Error>) -> Void) {
        guard let delegate = delegate else {
            fatalError("delegate is not set")
        }

        guard hasNextPage else {
            completion(.success([]))
            return
        }

        let cursorPredicate: CursorPredicate = {
            if let after = nextPageCursor {
                return CursorPredicate(cursor: .next(after), size: defaultNumberNotification)
            } else {
                return CursorPredicate(size: defaultNumberNotification)
            }
        }()

        delegate.pageForStore(self, name: name, cursor: cursorPredicate)
            .then { storePage in
                self.configurePagination(storePage)
                self.configureCount(storePage)

                let newEdges = storePage.edges
                self.edges.append(contentsOf: newEdges)
                completion(.success(storePage.obtainNotifications()))
            }.fail { error  in
                completion(.failure(error))
            }
    }

    public func fetchNewElements(completion: @escaping (Result<[Notification], Error>) -> Void) {

        if let newestCursor = edges.first?.cursor {
            recursiveNewElements(cursor: newestCursor, notifications: []) { result in
                switch result {
                case .success(let edges):
                    self.edges.insert(contentsOf: edges, at: 0)
                    completion(.success(edges.map { $0.node }))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            completion(.failure(MagicBellError("Cannot load new elements without initial fetch.")))
        }
    }

    private func recursiveNewElements(cursor: String, notifications: [Edge<Notification>], completion: @escaping (Result<[Edge<Notification>], Error>) -> Void) {

        let cursor = CursorPredicate(cursor: .previous(cursor), size: defaultNumberNotification)

        delegate?.pageForStore(self, name: name, cursor: cursor)
            .then { storePage in
                self.configureCount(storePage)
                var tempNotification = notifications
                tempNotification.insert(contentsOf: storePage.edges, at: 0)
                if storePage.pageInfo.hasPreviousPage, let cursor = storePage.pageInfo.startCursor {
                    self.recursiveNewElements(cursor: cursor, notifications: tempNotification, completion: completion)
                } else {
                    completion(.success(tempNotification))
                }
            }.fail { error in
                completion(.failure(error))
            }
    }

    public func clear() {
        edges = []
        totalCount = 0
        unreadCount = 0
        unseenCount = 0
        nextPageCursor = nil
        hasNextPage = true
    }

    private func configurePagination(_ page: StorePage) {
        let pageInfo = page.pageInfo
        nextPageCursor = pageInfo.endCursor
        hasNextPage = pageInfo.hasNextPage
    }

    private func configureCount(_ page: StorePage) {
        totalCount = page.totalCount
        unreadCount = page.unreadCount
        unseenCount = page.unseenCount
    }
}
