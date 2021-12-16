//
//  DeletePushSubscriptionInteractor.swift
//  MagicBell
//
//  Created by Javi on 8/12/21.
//

import Harmony

struct DeletePushSubscriptionInteractor {

    private let executor: Executor
    private let deletePushSubscriptionInteractor: Interactor.DeleteByQuery
    private let logger: Logger

    init(
        executor: Executor,
        deletePushSubscriptionInteractor: Interactor.DeleteByQuery,
        logger: Logger
    ) {
        self.executor = executor
        self.deletePushSubscriptionInteractor = deletePushSubscriptionInteractor
        self.logger = logger
    }

    func execute(deviceToken: String, userQuery: UserQuery) -> Future<Void> {
        return executor.submit { resolver in
            resolver.set(deletePushSubscriptionInteractor.execute(DeletePushSubscriptionQuery(user: userQuery, deviceToken: deviceToken), in: DirectExecutor()))
        }
    }
}
