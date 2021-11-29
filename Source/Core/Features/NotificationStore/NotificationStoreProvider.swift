//
//  NotificationStoreProvider.swift
//  MagicBell
//
//  Created by Javi on 28/11/21.
//

import Harmony


protocol NotificationStoreComponent {
    var notificationStoreCoordinator: NotificationStoreCoordinator { get }
}

class DefaultNotificationStoreModule: NotificationStoreComponent {
    
    private let storeComponent: StoreComponent
    private let userComponent: UserComponent
    private let logger: Logger
    
    internal init(storeComponent: StoreComponent,
                  userComponent: UserComponent,
                  logger: Logger) {
        self.storeComponent = storeComponent
        self.userComponent = userComponent
        self.logger = logger
    }
    
    lazy var notificationStoreCoordinator: NotificationStoreCoordinator = {
        NotificationStoreCoordinator(getStorePagesInteractor: storeComponent.getStorePagesInteractor(),
                                     getUserQueryInteractor: userComponent.getUserQueryInteractor(),
                                     logger: logger)
    }()
}
