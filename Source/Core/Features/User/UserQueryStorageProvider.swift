//
//  UserQueryStorageProvider.swift
//  MagicBell
//
//  Created by Javi on 3/12/21.
//

import Foundation
import Harmony

protocol UserQueryStorageComponent {
    func getUserQueryStorageProvider() -> AnyRepository<UserQuery>
}

class DefaultUserQueryStorageModule: UserQueryStorageComponent {

    private lazy var userQueryStorageRepository = AnyRepository(SingleDataSourceRepository(InMemoryDataSource<UserQuery>()))

    func getUserQueryStorageProvider() -> AnyRepository<UserQuery> {
        return userQueryStorageRepository
    }
}
