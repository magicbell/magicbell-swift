//
//  GetStorePagesInteractor.swift
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
                        userQuery: UserQuery,
                        in executor: Executor? = nil) -> Future<StorePage> {
        execute(
            contexts: [
                StoreContext("data", storePredicate, cursorPredicate)
            ],
            userQuery: userQuery,
            in: executor
        ).map { stores in
            guard let store = stores["data"] else {
                throw MagicBellError("Server didn't response correct data")
            }
            return store
        }
    }

    public func execute(
        contexts: [StoreContext],
        userQuery: UserQuery,
        in executor: Executor? = nil
    ) -> Future<[String: StorePage]> {
        let exec = (executor ?? self.executor)
        return exec.submit { resolver in
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
