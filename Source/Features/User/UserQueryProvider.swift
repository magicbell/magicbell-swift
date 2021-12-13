//
//  UserActionProvider.swift
//  MagicBell
//
//  Created by Javi on 3/12/21.
//

import Foundation
import Harmony

protocol UserQueryComponent {
    func getUserQueryInteractor() -> GetUserQueryInteractor
    func getStoreUserQueryInteractor() -> StoreUserQueryInteractor
    func getDeleteUserQueryInteractor() -> DeleteUserQueryInteractor
}

class DefaultUserQueryModule: UserQueryComponent {
    private let executor: Executor

    init(executor: Executor) {
        self.executor = executor
    }

    func getUserQueryInteractor() -> GetUserQueryInteractor {
        return GetUserQueryInteractor(
            getUserQuery: userQueryStorageRepository.toGetByQueryInteractor(executor)
        )
    }

    func getStoreUserQueryInteractor() -> StoreUserQueryInteractor {
        StoreUserQueryInteractor(
            storeUserQuery: userQueryStorageRepository.toPutByQueryInteractor(executor)
        )
    }

    func getDeleteUserQueryInteractor() -> DeleteUserQueryInteractor {
        DeleteUserQueryInteractor(
            deleteUserQuery: userQueryStorageRepository.toDeleteByQueryInteractor(executor)
        )
    }

    private lazy var userQueryStorageRepository = AnyRepository(SingleDataSourceRepository(InMemoryDataSource<UserQuery>()))

    func getUserQueryStorageProvider() -> AnyRepository<UserQuery> {
        return userQueryStorageRepository
    }
}
