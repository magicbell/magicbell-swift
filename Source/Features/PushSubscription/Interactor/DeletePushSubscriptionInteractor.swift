//
//  DeletePushSubscriptionInteractor.swift
//  MagicBell
//
//  Created by Javi on 8/12/21.
//

import Harmony

struct DeletePushSubscriptionInteractor {

    private let executor: Executor
    private let getDeviceTokenInteractor: Interactor.GetByQuery<String>
    private let deletePushSubscriptionInteractor: Interactor.DeleteByQuery
    private let logger: Logger

    init(executor: Executor,
         getDeviceTokenInteractor: Interactor.GetByQuery<String>,
         deletePushSubscriptionInteractor: Interactor.DeleteByQuery,
         logger: Logger) {
        self.executor = executor
        self.getDeviceTokenInteractor = getDeviceTokenInteractor
        self.deletePushSubscriptionInteractor = deletePushSubscriptionInteractor
        self.logger = logger
    }

    func execute(userQuery: UserQuery) -> Future<Void> {
        return executor.submit { resolver in
            let deviceToken = try getDeviceTokenInteractor.execute(DeviceTokenQuery(), in: DirectExecutor()).result.get()
            resolver.set(deletePushSubscriptionInteractor.execute(DeletePushSubscriptionQuery(user: userQuery, deviceToken: deviceToken), in: DirectExecutor()))
        }
    }
}
