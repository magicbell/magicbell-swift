//
//  StoreUserQueryInteractor.swift
//  MagicBell
//
//  Created by Joan Martin on 24/11/21.
//

import Harmony

struct StoreUserQueryInteractor {
    private let storeUserQueryInteractor: Interactor.PutByQuery<UserQuery>

    init(storeUserQuery: Interactor.PutByQuery<UserQuery>) {
        self.storeUserQueryInteractor = storeUserQuery
    }

    func execute(_ userQuery: UserQuery) {
        var error: Error?
        storeUserQueryInteractor
            .execute(userQuery, query: IdQuery("userQuery"), in: DirectExecutor())
            .result.get(error: &error)
    }
}
