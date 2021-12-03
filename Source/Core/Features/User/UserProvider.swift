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
    private let userQueryStorageRepository: AnyRepository<UserQuery>
    private let storeRealTimeComponent: StoreRealTimeComponent
    private let executor: Executor

    init(logger: Logger,
         configComponent: ConfigComponent,
         userQueryStorageRepository: AnyRepository<UserQuery>,
         storeRealTimeComponent: StoreRealTimeComponent,
         executor: Executor
    ) {
        self.logger = logger
        self.configComponent = configComponent
        self.userQueryStorageRepository = userQueryStorageRepository
        self.storeRealTimeComponent = storeRealTimeComponent
        self.executor = executor
    }

    func getLoginInteractor() -> LoginInteractor {
        let storeUserQuery = StoreUserQueryInteractor(
            storeUserQuery: userQueryStorageRepository.toPutByQueryInteractor(executor)
        )

        return LoginInteractor(
            logger: logger,
            getUserConfig: configComponent.getGetConfigInteractor(),
            storeUserQuery: storeUserQuery,
            storeRealTimeComponent: storeRealTimeComponent
        )
    }

    func getLogoutInteractor() -> LogoutInteractor {
        let deleteUserQuery = DeleteUserQueryInteractor(
            deleteUserQuery: userQueryStorageRepository.toDeleteByQueryInteractor(executor)
        )
        return LogoutInteractor(
            logger: logger,
            deleteUserConfig: configComponent.getDeleteConfigInteractor(),
            deleteUserQuery: deleteUserQuery,
            storeRealTimeComponent: storeRealTimeComponent
        )
    }
}
