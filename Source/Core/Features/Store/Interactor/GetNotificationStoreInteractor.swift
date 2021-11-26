//
//  GetNotificationStoreInteractor.swift
//  MagicBell
//
//  Created by Javi on 26/11/21.
//

import Harmony

struct GetNotificationStoreInteractor {
    private let executor: Executor
    private let getStoreNotificationInteractor: Interactor.GetByQuery<Stores>

    init(executor: Executor, getStoreNotificationInteractor: Interactor.GetByQuery<Stores>) {
        self.executor = executor
        self.getStoreNotificationInteractor = getStoreNotificationInteractor
    }

    func execute(name: String,
                 storePredicate: StorePredicate,
                 storePagination: StorePagination,
                 userQuery: UserQuery) -> Future<Store> {
        return executor.submit { resolver in
            let stores = try getStoreNotificationInteractor.execute(
                NotificationStoreQuery(name: name,
                                       storeContext: StoreContext(
                                        name: name,
                                        storePredicate: storePredicate,
                                        storePagination: storePagination),
                                       user: userQuery)
            ).result.get()
            if let store = stores.stores.first(where: { $0.key == name })?.value {
                resolver.set(store)
            } else {
                resolver.set(MagicBellError("Store not found"))
            }
        }
    }
}
