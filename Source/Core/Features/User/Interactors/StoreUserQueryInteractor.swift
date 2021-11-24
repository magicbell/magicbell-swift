//
//  StoreUserQueryInteractor.swift
//  MagicBell
//
//  Created by Joan Martin on 24/11/21.
//

import Harmony

struct StoreUserQueryInteractor {
    private let storeUserQuery: Interactor.PutByQuery<UserQuery>

    init(storeUserQuery: Interactor.PutByQuery<UserQuery>) {
        self.storeUserQuery = storeUserQuery
    }

    func execute(_ userQuery: UserQuery) {
        var error: Error?
        storeUserQuery
            .execute(userQuery, query: IdQuery("userQuery"), in: DirectExecutor())
            .fail { error in
                fatalError("Storing a userQuery should never fail: \(error)")
            }
            .result.get(error: &error)
    }
}
