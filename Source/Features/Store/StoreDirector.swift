//
//  StoreCoordinator.swift
//  MagicBell
//
//  Created by Joan Martin on 14/12/21.
//

import Foundation
import Harmony

public protocol StoreDirector {
    /// Returns a notification store for the given predicate.
    /// - Parameters:
    ///    - predicate: Notification store's predicate. Define an scope for the notification store. Read, Seen, Archive, Categories, Topics and inApp.
    /// - Returns: A `NotificationStore` with all the actions. MarkNotifications, MarkAllNotifications, FetchNotifications, ReloadStore.
    func with(predicate: StorePredicate) -> NotificationStore

    /// Disposes a notification store for the given predicate if exists. To be called when a notification store is no longer needed.
    /// - Parameters:
    ///    - predicate: Notification store's predicate.
    func disposeWith(predicate: StorePredicate)

    /// Disposes all created stores.1
    func disposeAll()
}

class RealTimeByPredicateStoreDirector: StoreDirector {

    private var stores: [NotificationStore] = []

    private let logger: Logger
    private let userQuery: UserQuery
    private let fetchStorePageInteractor: FetchStorePageInteractor
    private let actionNotificationInteractor: ActionNotificationInteractor
    private let deleteNotificationInteractor: DeleteNotificationInteractor

    private let storeRealTime: StoreRealTime

    init(
        logger: Logger,
        userQuery: UserQuery,
        fetchStorePageInteractor: FetchStorePageInteractor,
        actionNotificationInteractor: ActionNotificationInteractor,
        deleteNotificationInteractor: DeleteNotificationInteractor,
        storeRealTime: StoreRealTime
    ) {
        self.logger = logger
        self.userQuery = userQuery
        self.fetchStorePageInteractor = fetchStorePageInteractor
        self.actionNotificationInteractor = actionNotificationInteractor
        self.deleteNotificationInteractor = deleteNotificationInteractor
        self.storeRealTime = storeRealTime

        // Start listening for events
        storeRealTime.startListening()
    }

    deinit {
        disposeAll()

        // Stop listening for events
        storeRealTime.stopListening()
    }

    func with(predicate: StorePredicate) -> NotificationStore {
        if let store = stores.first(where: { $0.predicate.hashValue == predicate.hashValue }) {
            return store
        }

        let store = NotificationStore(
            name: UUID().uuidString,
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

    func disposeWith(predicate: StorePredicate) {
        if let storeIndex = stores.firstIndex(where: { $0.predicate.hashValue == predicate.hashValue }) {
            let store = stores[storeIndex]
            storeRealTime.removeObserver(store)
            stores.remove(at: storeIndex)
        }
    }

    func disposeAll() {
        stores.forEach { store in
            storeRealTime.removeObserver(store)
        }
        stores.removeAll()
    }
}
