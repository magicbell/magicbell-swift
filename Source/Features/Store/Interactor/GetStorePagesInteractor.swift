//
// By downloading or using this software made available by MagicBell, Inc.
// ("MagicBell") or any documentation that accompanies it (collectively, the
// "Software"), you and the company or entity that you represent (collectively,
// "you" or "your") are consenting to be bound by and are becoming a party to this
// License Agreement (this "Agreement"). You hereby represent and warrant that you
// are authorized and lawfully able to bind such company or entity that you
// represent to this Agreement.  If you do not have such authority or do not agree
// to all of the terms of this Agreement, you may not download or use the Software.
//
// For more information, read the LICENSE file.
//

import Harmony

struct GetStorePagesInteractor {
    private let executor: Executor
    private let getStoreNotificationInteractor: Interactor.GetByQuery<[String: StorePage]>
    
    init(
        executor: Executor,
        getStoreNotificationInteractor: Interactor.GetByQuery<[String: StorePage]>
    ) {
        self.executor = executor
        self.getStoreNotificationInteractor = getStoreNotificationInteractor
    }
    
    func execute(storePredicate: StorePredicate,
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
    
    func execute(
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
