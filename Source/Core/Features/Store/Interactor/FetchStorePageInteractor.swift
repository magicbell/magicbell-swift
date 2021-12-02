//
//  FetchStorePageInteractor.swift
//  MagicBell
//
//  Created by Javi on 2/12/21.
//

import Harmony

struct FetchStorePageInteractor {

    private let executor: Executor
    private let getUserQueryInteractor: GetUserQueryInteractor
    private let getStorePagesInteractor: GetStorePagesInteractor

    init(executor: Executor, getUserQueryInteractor: GetUserQueryInteractor, getStorePagesInteractor: GetStorePagesInteractor) {
        self.executor = executor
        self.getUserQueryInteractor = getUserQueryInteractor
        self.getStorePagesInteractor = getStorePagesInteractor
    }

    func execute(storePredicate: StorePredicate,
                 cursorPredicate: CursorPredicate) -> Future<StorePage> {
        return executor.submit { resolver in
            // Do catch try to avoid
            let userQuery = try getUserQueryInteractor.execute()
            resolver.set(getStorePagesInteractor.execute(storePredicate: storePredicate, cursorPredicate: cursorPredicate, userQuery: userQuery))
        }
    }
}
