//
//  FetchStorePageInteractor.swift
//  MagicBell
//
//  Created by Javi on 2/12/21.
//

import Harmony

protocol FetchStorePageInteractor {
    func execute(
        storePredicate: StorePredicate,
        userQuery: UserQuery,
        cursorPredicate: CursorPredicate
    ) -> Future<StorePage>
}

struct FetchStorePageDefaultInteractor: FetchStorePageInteractor {

    private let executor: Executor
    private let getStorePagesInteractor: GetStorePagesInteractor

    init(executor: Executor, getStorePagesInteractor: GetStorePagesInteractor) {
        self.executor = executor
        self.getStorePagesInteractor = getStorePagesInteractor
    }

    func execute(storePredicate: StorePredicate,
                 userQuery: UserQuery,
                 cursorPredicate: CursorPredicate) -> Future<StorePage> {
        return executor.submit { resolver in
            let storePage = try getStorePagesInteractor.execute(storePredicate: storePredicate,
                                                                cursorPredicate: cursorPredicate,
                                                                userQuery: userQuery,
                                                                in: DirectExecutor()).result.get()
            resolver.set(storePage)
        }
    }
}
