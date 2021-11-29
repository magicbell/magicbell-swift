//
//  NotificationStoreManager.swift
//  MagicBell
//
//  Created by Javi on 28/11/21.
//

import Harmony

protocol NotificationStoreFactory {
    func createNotificationStore(name: String?, storePredicate: StorePredicate) throws -> NotificationStore
}

class NotificationStoreCoordinator: NotificationStoreDelegate, NotificationStoreFactory {

    private var notificationStores: [NotificationStore] = []
    
    private let getStorePagesInteractor: GetStorePagesInteractor
    private let getUserQueryInteractor: GetUserQueryInteractor
    private let logger: Logger

    init(getStorePagesInteractor: GetStorePagesInteractor,
         getUserQueryInteractor: GetUserQueryInteractor,
         logger: Logger) {
        self.getStorePagesInteractor = getStorePagesInteractor
        self.getUserQueryInteractor = getUserQueryInteractor
        self.logger = logger
    }

    func createNotificationStore(name: String?, storePredicate: StorePredicate) throws -> NotificationStore {
        if self.notificationStores.map({ $0.storePredicate }).contains(storePredicate) {
            throw MagicBellError("StorePredicate already exists")
        } else {
            let newNotificationStore: NotificationStore
            if let name = name {
                newNotificationStore = NotificationStore(name: name, storePredicate: storePredicate, delegate: self, logger: logger)
            } else {
                newNotificationStore = NotificationStore(name: UUID().uuidString, storePredicate: storePredicate, delegate: self, logger: logger)
            }

            notificationStores.append(newNotificationStore)
            return newNotificationStore
        }
    }

    func getNotificationStore(name: String) -> NotificationStore? {
        return notificationStores.first { notificationStore in
            notificationStore.name == name
        }
    }

    func pageForStore(_ store: NotificationStore, name: String, cursor: CursorPredicate) -> Future<StorePage> {
        Future { resolver in
            let userQuery = try getUserQueryInteractor.execute()
            resolver.set(self.getStorePagesInteractor.execute(storePredicate: store.storePredicate, cursorPredicate: cursor, userQuery: userQuery))
        }
    }
}
