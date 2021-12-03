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
}

class DefaultUserQueryModule: UserQueryComponent {
    private let userQueryStorageRepository: AnyRepository<UserQuery>
    private let executor: Executor

    init(userQueryStorageRepository: AnyRepository<UserQuery>,
         executor: Executor) {
        self.userQueryStorageRepository = userQueryStorageRepository
        self.executor = executor
    }

    func getUserQueryInteractor() -> GetUserQueryInteractor {
        return GetUserQueryInteractor(
            getUserQuery: userQueryStorageRepository.toGetByQueryInteractor(executor)
        )
    }
}
