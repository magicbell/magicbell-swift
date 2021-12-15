//
//  SendPushSubscriptionInteractor.swift
//  MagicBell
//
//  Created by Javi on 8/12/21.
//

import Harmony

struct SendPushSubscriptionInteractor {

    private let executor: Executor
    private let getDeviceTokenInteractor: Interactor.GetByQuery<String>
    private let putPushSubscriptionInteractor: Interactor.PutByQuery<PushSubscription>
    private let logger: Logger

    init(
        executor: Executor,
        getDeviceTokenInteractor: Interactor.GetByQuery<String>,
        putPushSubscriptionInteractor: Interactor.PutByQuery<PushSubscription>,
        logger: Logger
    ) {
        self.executor = executor
        self.getDeviceTokenInteractor = getDeviceTokenInteractor
        self.putPushSubscriptionInteractor = putPushSubscriptionInteractor
        self.logger = logger
    }

    func execute(userQuery: UserQuery) -> Future<PushSubscription> {
        return executor.submit { resolver in
            let deviceToken = try getDeviceTokenInteractor.execute(DeviceTokenQuery(), in: DirectExecutor()).result.get()
            let pushSubscription = PushSubscription(id: nil, deviceToken: deviceToken, platform: PushSubscription.platformIOS)
            let pushSubscriptionQuery = RegisterPushSubscriptionQuery(user: userQuery)
            resolver.set(putPushSubscriptionInteractor.execute(pushSubscription, query: pushSubscriptionQuery, in: DirectExecutor()))
        }
    }
}
