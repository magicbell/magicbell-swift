//
//  GetNotificationStoreInteractor.swift
//  MagicBell
//
//  Created by Javi on 26/11/21.
//

import Harmony

public struct GetStorePagesInteractor {
    private let executor: Executor
    private let getStoreNotificationInteractor: Interactor.GetByQuery<[String: StorePage]>

    init(
        executor: Executor,
        getStoreNotificationInteractor: Interactor.GetByQuery<[String: StorePage]>
    ) {
        self.executor = executor
        self.getStoreNotificationInteractor = getStoreNotificationInteractor
    }

    public func execute(storePredicate: StorePredicate,
                        cursorPredicate: CursorPredicate,
                        userQuery: UserQuery) -> Future<StorePage> {
        execute(
            contexts: [
                StoreContext("data", storePredicate, cursorPredicate)
            ],
            userQuery: userQuery
        ).map { stores in
            guard let store = stores["data"] else {
                throw MagicBellError("Server didn't response correct data")
            }
            return store
        }
    }

    public func execute(
        contexts: [StoreContext],
        userQuery: UserQuery
    ) -> Future<[String: StorePage]> {
        return executor.submit { resolver in
            let stores = try getStoreNotificationInteractor.execute(
                StoreQuery(
                    contexts: contexts,
                    userQuery: userQuery
                ),
                in: DirectExecutor()
            ).result.get()
            resolver.set(stores)
        }
    }
}
