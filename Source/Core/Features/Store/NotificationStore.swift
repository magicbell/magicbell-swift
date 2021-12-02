//
//  NotificationStore.swift
//  MagicBell
//
//  Created by Javi on 28/11/21.
//

import Harmony

public class NotificationStore {
    private let defaultNumberNotification = 20
    
    private let getUserQueryInteractor: GetUserQueryInteractor
    private let fetchStorePageInteractor: FetchStorePageInteractor
    private let actionNotificationInteractor: ActionNotificationInteractor
    private let deleteNotificationInteractor: DeleteNotificationInteractor
    
    public let name: String
    public let storePredicate: StorePredicate
    public var notifications: [Notification] { edges.map { $0.node } }
    private var edges: [Edge<Notification>] = []
    public private(set) var totalCount: Int = 0
    public private(set) var unreadCount: Int = 0
    public private(set) var unseenCount: Int = 0
    
    private let logger: Logger
    
    private var nextPageCursor: String?
    public private(set) var hasNextPage = true
    
    init(name: String,
         storePredicate: StorePredicate,
         getUserQueryInteractor: GetUserQueryInteractor,
         fetchStorePageInteractor: FetchStorePageInteractor,
         actionNotificationInteractor: ActionNotificationInteractor,
         deleteNotificationInteractor: DeleteNotificationInteractor,
         logger: Logger) {
        self.name = name
        self.storePredicate = storePredicate
        self.getUserQueryInteractor = getUserQueryInteractor
        self.fetchStorePageInteractor = fetchStorePageInteractor
        self.actionNotificationInteractor = actionNotificationInteractor
        self.deleteNotificationInteractor = deleteNotificationInteractor
        self.logger = logger
    }

    /// Returns an array of notifications. It can be called multiple times to obtain all the notifications.
    /// - Parameters:
    ///    - refresh: Restore the notification store to the initial status
    ///    - completion: Closure with a `Result<[Notification], Error>`
    public func fetch(refresh: Bool = false, completion: @escaping (Result<[Notification], Error>) -> Void) {
        if refresh {
            clear()
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
        
        fetchStorePageInteractor.execute(storePredicate: storePredicate, cursorPredicate: cursorPredicate).then { storePage in
            self.configurePagination(storePage)
            self.configureCount(storePage)

            let newEdges = storePage.edges
            self.edges.append(contentsOf: newEdges)
            let notifications = newEdges.map { notificationEdge in
                notificationEdge.node
            }
            completion(.success(notifications))
        }.fail { error in
            completion(.failure(error))
        }
    }

    /// Returns an array of notifications that are newer from the last fetched time. It returns all the notifications, doesn't have pagination.
    /// - Parameters:
    ///    - completion: Closure with a `Result<[Notification], Error>`
    public func fetchNewElements(completion: @escaping (Result<[Notification], Error>) -> Void) {
        if let newestCursor = edges.first?.cursor {
            recursiveNewElements(cursor: newestCursor, notifications: []) { result in
                switch result {
                case .success(let edges):
                    self.edges.insert(contentsOf: edges, at: 0)
                    completion(.success(edges.map {
                        $0.node
                    }))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            completion(.failure(MagicBellError("Cannot load new elements without initial fetch.")))
        }
    }
    
    private func recursiveNewElements(cursor: String, notifications: [Edge<Notification>], completion: @escaping (Result<[Edge<Notification>], Error>) -> Void) {
        let cursorPredicate = CursorPredicate(cursor: .previous(cursor), size: defaultNumberNotification)
        fetchStorePageInteractor.execute(storePredicate: storePredicate, cursorPredicate: cursorPredicate).then { storePage in
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

    /// Removes the notification from the store.
    /// - Parameters:
    ///    - notification: Notification will be removed.
    ///    - completion: Closure with a `Error`. Success if error is nil.
    public func removeNotification(_ notification: Notification, completion: @escaping (Error?) -> Void) {
        deleteNotificationInteractor.execute(notificationId: notification.id).then { _ in
            if let notificationIndex = self.edges.firstIndex(where: { $0.node.id == notification.id }) {
                self.edges.remove(at: notificationIndex)
                completion(nil)
            } else {
                completion(MagicBellError("Notification doesn't exist"))
            }
        }
    }

    /// Marks a notification as read.
    /// - Parameters:
    ///    - notification: Notification will be marked as read and seen.
    ///    - completion: Closure with a `Error`. Success if error is nil.
    public func markNotificationAsRead(_ notification: Notification, completion: @escaping (Error?) -> Void) {
        executeNotificationAction(
            notification: notification,
            action: .markAsRead,
            modificationsBlock: {
                let now = Date()
                $0.readAt = now
                $0.seenAt = now
            },
            completion: completion)
    }

    /// Marks a notification as unread.
    /// - Parameters:
    ///    - notification: Notification will be marked as unread.
    ///    - completion: Closure with a `Error`. Success if error is nil.
    public func markNotificationAsUnread(_ notification: Notification, completion: @escaping (Error?) -> Void) {
        executeNotificationAction(
            notification: notification,
            action: .markAsUnread,
            modificationsBlock: { $0.readAt = nil },
            completion: completion)
    }

    /// Marks a notification as archived.
    /// - Parameters:
    ///    - notification: Notification will be marked as archived.
    ///    - completion: Closure with a `Error`. Success if error is nil.
    public func markNotificationAsArchived(_ notification: Notification, completion: @escaping (Error?) -> Void) {
        executeNotificationAction(
            notification: notification,
            action: .archive,
            modificationsBlock: { $0.archivedAt = Date() },
            completion: completion)
    }

    /// Marks a notification as unarchived.
    /// - Parameters:
    ///    - notification: Notification will be marked as unarchived.
    ///    - completion: Closure with a `Error`. Success if error is nil.
    public func markNotificationAsUnarchived(_ notification: Notification, completion: @escaping (Error?) -> Void) {
        executeNotificationAction(
            notification: notification,
            action: .unarchive,
            modificationsBlock: { $0.archivedAt = nil },
            completion: completion)
    }
    
    private func executeNotificationAction(notification: Notification,
                                           action: NotificationActionQuery.Action,
                                           modificationsBlock: @escaping (inout Notification) -> Void,
                                           completion: @escaping (Error?) -> Void) {
        actionNotificationInteractor.execute(action: action, notificationId: notification.id).then { _ in
            if let notificationIndex = self.edges.firstIndex(where: { $0.node.id == notification.id }) {
                var notificationToModify = self.edges[notificationIndex].node
                modificationsBlock(&notificationToModify)
                self.edges[notificationIndex].node = notificationToModify
                completion(nil)
            } else {
                completion(MagicBellError("Notification not found in store"))
            }
        }.fail { error in
            completion(error)
        }
    }

    /// Marks all notifications as read.
    /// - Parameters:
    ///    - completion: Closure with a `Error`. Success if error is nil.
    public func markAllNotificationsAsRead(completion: @escaping (Error?) -> Void) {
        executeAllNotificationAction(
            action: .markAllAsRead,
            modificationsBlock: {
                let now = Date()
                $0.readAt = now
                $0.seenAt = now
            },
            completion: completion)
    }

    /// Marks all notifications as seen.
    /// - Parameters:
    ///    - completion: Closure with a `Error`. Success if error is nil.
    public func markAllNotificationAsSeen(completion: @escaping (Error?) -> Void) {
        executeAllNotificationAction(
            action: .markAllAsSeen,
            modificationsBlock: {
                $0.seenAt = Date()
            },
            completion: completion)
    }
    
    private func executeAllNotificationAction(action: NotificationActionQuery.Action,
                                              modificationsBlock: @escaping (inout Notification) -> Void,
                                              completion: @escaping (Error?) -> Void) {
        actionNotificationInteractor.execute(action: action).then { _ in
            for i in self.edges.indices {
                var notification = self.edges[i].node
                modificationsBlock(&notification)
            }
            completion(nil)
        }.fail { error in
            completion(error)
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
