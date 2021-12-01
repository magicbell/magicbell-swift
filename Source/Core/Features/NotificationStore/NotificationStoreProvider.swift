//
//  NotificationStoreProvider.swift
//  MagicBell
//
//  Created by Javi on 28/11/21.
//

import Harmony


protocol NotificationStoreComponent {
    var notificationStoreFactory: NotificationStoreFactory { get }
}

class DefaultNotificationStoreModule: NotificationStoreComponent {

    private let storeComponent: StoreComponent
    private let userComponent: UserComponent
    private let notificationComponent: NotificationComponent
    let notificationStoreFactory: NotificationStoreFactory
    private let executor: Executor
    private let logger: Logger

    init(storeComponent: StoreComponent,
         userComponent: UserComponent,
         notificationComponent: NotificationComponent,
         executor: Executor,
         logger: Logger) {
        self.storeComponent = storeComponent
        self.userComponent = userComponent
        self.notificationComponent = notificationComponent
        self.notificationStoreFactory = DefautNotificationStoreFactory(
            getUserQueryInteractor: userComponent.getUserQueryInteractor(),
            getPageStoreInteractor: storeComponent.getStorePagesInteractor(),
            actionNotificationInteractor: notificationComponent.getActionNotificationInteractor(),
            logger: logger)
        self.executor = executor
        self.logger = logger
    }
}
