//
//  UserProvider.swift
//  MagicBell
//
//  Created by Javi on 23/11/21.
//

import Foundation
import Harmony

protocol UserComponent {
    func getLoginInteractor() -> LoginInteractor
    func getLogoutInteractor() -> LogoutInteractor
}

class DefaultUserComponent: UserComponent {

    private let logger: Logger
    private let configComponent: ConfigComponent
    private let userQueryComponent: UserQueryComponent
    private let storeRealTimeComponent: StoreRealTimeComponent
    private let pushSubscriptionComponent: PushSubscriptionComponent
    private let executor: Executor

    init(logger: Logger,
         configComponent: ConfigComponent,
         userQueryComponent: UserQueryComponent,
         storeRealTimeComponent: StoreRealTimeComponent,
         pushSubscriptionComponent: PushSubscriptionComponent,
         executor: Executor
    ) {
        self.logger = logger
        self.configComponent = configComponent
        self.userQueryComponent = userQueryComponent
        self.storeRealTimeComponent = storeRealTimeComponent
        self.pushSubscriptionComponent = pushSubscriptionComponent
        self.executor = executor
    }

    func getLoginInteractor() -> LoginInteractor {
        return LoginInteractor(
            logger: logger,
            getUserConfig: configComponent.getGetConfigInteractor(),
            storeUserQuery: userQueryComponent.getStoreUserQueryInteractor(),
            storeRealTime: storeRealTimeComponent.getStoreRealmTime(),
            sendPushSubscriptionInteractor: pushSubscriptionComponent.getSendPushSubscriptionInteractor()
        )
    }

    func getLogoutInteractor() -> LogoutInteractor {
        return LogoutInteractor(
            deleteUserConfig: configComponent.getDeleteConfigInteractor(),
            deleteUserQuery: userQueryComponent.getDeleteUserQueryInteractor(),
            storeRealTime: storeRealTimeComponent.getStoreRealmTime(),
            deletePushSubscriptionInteractor: pushSubscriptionComponent.getDeletePushSubscriptionInteractor(),
            logger: logger
        )
    }
}
