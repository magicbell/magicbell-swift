//
//  NotificationStoreFactory.swift
//  MagicBell
//
//  Created by Javi on 1/12/21.
//

import Harmony

protocol NotificationStoreFactory {
    func createNotificationStore(name: String?, predicate: StorePredicate) -> NotificationStore
}

class DefautNotificationStoreFactory: NotificationStoreFactory {
    private let getUserQueryInteractor: GetUserQueryInteractor
    private let getPageStoreInteractor: GetStorePagesInteractor
    private let actionNotificationInteractor: Interactor.PutByQuery<Void>
    private let logger: Logger

    init(getUserQueryInteractor: GetUserQueryInteractor,
         getPageStoreInteractor: GetStorePagesInteractor,
         actionNotificationInteractor: Interactor.PutByQuery<Void>,
         logger: Logger) {
        self.getUserQueryInteractor = getUserQueryInteractor
        self.getPageStoreInteractor = getPageStoreInteractor
        self.actionNotificationInteractor = actionNotificationInteractor
        self.logger = logger
    }

    func createNotificationStore(name: String?, predicate: StorePredicate) -> NotificationStore {
        NotificationStore(name: name ?? UUID().uuidString,
                          storePredicate: predicate,
                          getUserQueryInteractor: getUserQueryInteractor,
                          getStorePagesInteractor: getPageStoreInteractor,
                          actionNotificationInteractor: actionNotificationInteractor,
                          logger: logger)
    }
}
