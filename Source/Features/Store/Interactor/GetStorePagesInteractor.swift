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
    private let getStoreNotificationInteractor: Interactor.GetByQuery<StorePage>
    
    init(
        executor: Executor,
        getStoreNotificationInteractor: Interactor.GetByQuery<StorePage>
    ) {
        self.executor = executor
        self.getStoreNotificationInteractor = getStoreNotificationInteractor
    }
    
    func execute(storePredicate: StorePredicate,
                 pagePredicate: StorePagePredicate,
                 userQuery: UserQuery,
                 in executor: Executor? = nil) -> Future<StorePage> {
        execute(
            context: StoreContext(storePredicate, pagePredicate),
            userQuery: userQuery,
            in: executor
        )
    }
    
    func execute(context: StoreContext, userQuery: UserQuery, in executor: Executor? = nil) -> Future<StorePage> {
        let exec = (executor ?? self.executor)
        return exec.submit { resolver in
            let store = try getStoreNotificationInteractor.execute(
                StoreQuery(
                    context: context,
                    userQuery: userQuery
                ),
                in: DirectExecutor()
            ).result.get()
            resolver.set(store)
        }
    }
}
