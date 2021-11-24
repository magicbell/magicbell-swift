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
    func getUserQueryInteractor() -> GetUserQueryInteractor
}

class DefaultUserComponent: UserComponent {

    private let logger: Logger
    private let configComponent: ConfigComponent
    private let executor: Executor

    init(logger: Logger,
         configComponent: ConfigComponent,
         executor: Executor
    ) {
        self.logger = logger
        self.configComponent = configComponent
        self.executor = executor
    }

    private lazy var userQueryStorageRepository = SingleDataSourceRepository(InMemoryDataSource<UserQuery>())

    func getLoginInteractor() -> LoginInteractor {
        let storeUserQuery = StoreUserQueryInteractor(
            storeUserQuery: userQueryStorageRepository.toPutByQueryInteractor(executor)
        )

        return LoginInteractor(
            logger: logger,
            getUserConfig: configComponent.getGetConfigInteractor(),
            storeUserQuery: storeUserQuery
        )
    }

    func getLogoutInteractor() -> LogoutInteractor {
        let deleteUserQuery = DeleteUserQueryInteractor(
            deleteUserQuery: userQueryStorageRepository.toDeleteByQueryInteractor(executor)
        )
        return LogoutInteractor(
            logger: logger,
            deleteUserConfig: configComponent.getDeleteConfigInteractor(),
            deleteUserQuery: deleteUserQuery
        )
    }

    func getUserQueryInteractor() -> GetUserQueryInteractor {
        return GetUserQueryInteractor(
            getUserQuery: userQueryStorageRepository.toGetByQueryInteractor(executor)
        )
    }
}
