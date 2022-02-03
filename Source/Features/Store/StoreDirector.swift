//
// By downloading or using this software made available by MagicBell, Inc.
// ("MagicBell") or any documentation that accompanies it (collectively, the
// "Software"), you and the company or entity that you represent (collectively,
// "you" or "your") are consenting to be bound by and are becoming a party to this
// License Agreement (this "Agreement"). You hereby represent and warrant that you
// are authorized and lawfully able to bind such company or entity that you
// represent to this Agreement.  If you do not have such authority or do not agree
// to all of the terms of this Agreement, you may not download or use the Software.
//
// For more information, read the LICENSE file.
//

import Foundation
import Harmony

/// An store director is the class responsible of creating and managing `NotificationStore` objects.
public protocol StoreDirector {
    /// Returns a notification store for the given predicate.
    /// - Parameters:
    ///    - predicate: Notification store's predicate. Define an scope for the notification store. Read, Seen, Archive, Categories, Topics and inApp.
    /// - Returns: A `NotificationStore` with all the actions. MarkNotifications, MarkAllNotifications, FetchNotifications, ReloadStore.
    func build(predicate: StorePredicate) -> NotificationStore

    /// Disposes a notification store for the given predicate if exists. To be called when a notification store is no longer needed.
    /// - Parameters:
    ///    - predicate: Notification store's predicate.
    func dispose(predicate: StorePredicate)
}

public extension StoreDirector {
    /// Return the store for all notificaionts
    /// - Returns: A notification store
    func forAll() -> NotificationStore {
        build(predicate: StorePredicate())
    }

    /// Return the store for unread notificaionts
    /// - Returns: A notification store
    func forUnread() -> NotificationStore {
        build(predicate: StorePredicate(read: .unread))
    }

    /// Return the store for read notificaionts
    /// - Returns: A notification store
    func forRead() -> NotificationStore {
        build(predicate: StorePredicate(read: .read))
    }

    /// Return the store for notifications with the given categories
    /// - Parameter categories: The list of categories
    /// - Returns: A notification store
    func forCategories(_ categories: [String]) -> NotificationStore {
        build(predicate: StorePredicate(categories: categories))
    }

    /// Return the store for notifications with the given topics
    /// - Parameter categories: The list of topics
    /// - Returns: A notification store
    func forTopics(_ topics: [String]) -> NotificationStore {
        build(predicate: StorePredicate(topics: topics))
    }
}

protocol InternalStoreDirector: StoreDirector {
    /// Logout
    func logout()
}


class RealTimeByPredicateStoreDirector: InternalStoreDirector {

    private var stores: [NotificationStore] = []

    private let logger: Logger
    private let userQuery: UserQuery
    private let fetchStorePageInteractor: FetchStorePageInteractor
    private let actionNotificationInteractor: ActionNotificationInteractor
    private let deleteNotificationInteractor: DeleteNotificationInteractor
    private let getConfigInteractor: GetConfigInteractor
    private let deleteConfigInteractor: DeleteConfigInteractor
    private let storeRealTime: StoreRealTime

    init(
        logger: Logger,
        userQuery: UserQuery,
        fetchStorePageInteractor: FetchStorePageInteractor,
        actionNotificationInteractor: ActionNotificationInteractor,
        deleteNotificationInteractor: DeleteNotificationInteractor,
        getConfigInteractor: GetConfigInteractor,
        deleteConfigInteractor: DeleteConfigInteractor,
        storeRealTime: StoreRealTime
    ) {
        self.logger = logger
        self.userQuery = userQuery
        self.fetchStorePageInteractor = fetchStorePageInteractor
        self.actionNotificationInteractor = actionNotificationInteractor
        self.deleteNotificationInteractor = deleteNotificationInteractor
        self.getConfigInteractor = getConfigInteractor
        self.deleteConfigInteractor = deleteConfigInteractor
        self.storeRealTime = storeRealTime

        startRealTimeConnection()
    }

    deinit {
        logout()
    }

    private func startRealTimeConnection() {
        getConfigInteractor
            .execute(forceRefresh: false, userQuery: userQuery)
            .then { config in
                self.storeRealTime.startListening(with: config)
            }
            .fail { error in
                self.logger.info(tag: magicBellTag, "User Config couldn't be retrieved. Attempting to fetch config and connect to ably in 30 seconds: \(error)")
                Timer.scheduledTimer(withTimeInterval: 30, repeats: false) { [self] _ in
                    startRealTimeConnection()
                }
            }
    }

    func build(predicate: StorePredicate) -> NotificationStore {
        if let store = stores.first(where: { $0.predicate.hashValue == predicate.hashValue }) {
            return store
        }

        let store = NotificationStore(
            predicate: predicate,
            userQuery: userQuery,
            fetchStorePageInteractor: fetchStorePageInteractor,
            actionNotificationInteractor: actionNotificationInteractor,
            deleteNotificationInteractor: deleteNotificationInteractor,
            logger: logger
        )

        storeRealTime.addObserver(store)
        stores.append(store)

        return store
    }

    func dispose(predicate: StorePredicate) {
        if let storeIndex = stores.firstIndex(where: { $0.predicate.hashValue == predicate.hashValue }) {
            let store = stores[storeIndex]
            storeRealTime.removeObserver(store)
            stores.remove(at: storeIndex)
        }
    }

    func logout() {
        stores.forEach { store in
            storeRealTime.removeObserver(store)
        }
        stores.removeAll()
        _ = deleteConfigInteractor.execute()
        storeRealTime.stopListening()
    }
}
