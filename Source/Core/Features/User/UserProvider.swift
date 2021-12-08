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
    private let executor: Executor

    init(logger: Logger,
         configComponent: ConfigComponent,
         userQueryComponent: UserQueryComponent,
         storeRealTimeComponent: StoreRealTimeComponent,
         executor: Executor
    ) {
        self.logger = logger
        self.configComponent = configComponent
        self.userQueryComponent = userQueryComponent
        self.storeRealTimeComponent = storeRealTimeComponent
        self.executor = executor
    }

    func getLoginInteractor() -> LoginInteractor {
        return LoginInteractor(
            logger: logger,
            getUserConfig: configComponent.getGetConfigInteractor(),
            storeUserQuery: userQueryComponent.getStoreUserQueryInteractor(),
            storeRealTimeComponent: storeRealTimeComponent
        )
    }

    func getLogoutInteractor() -> LogoutInteractor {
        return LogoutInteractor(
            logger: logger,
            deleteUserConfig: configComponent.getDeleteConfigInteractor(),
            deleteUserQuery: userQueryComponent.getDeleteUserQueryInteractor(),
            storeRealTimeComponent: storeRealTimeComponent
        )
    }
}
