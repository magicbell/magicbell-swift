//
//  SendPushSubscriptionInteractor.swift
//  MagicBell
//
//  Created by Javi on 8/12/21.
//

import Harmony

struct SendPushSubscriptionInteractor {
    private let executor: Executor
    private let putPushSubscriptionInteractor: Interactor.PutByQuery<PushSubscription>
    private let logger: Logger

    init(
        executor: Executor,
        putPushSubscriptionInteractor: Interactor.PutByQuery<PushSubscription>,
        logger: Logger
    ) {
        self.executor = executor
        self.putPushSubscriptionInteractor = putPushSubscriptionInteractor
        self.logger = logger
    }

    func execute(deviceToken: String, userQuery: UserQuery) -> Future<PushSubscription> {
        executor.submit { resolver in
            let pushSubscription = PushSubscription(id: nil, deviceToken: deviceToken, platform: PushSubscription.platformIOS)
            let pushSubscriptionQuery = RegisterPushSubscriptionQuery(user: userQuery)
            resolver.set(putPushSubscriptionInteractor.execute(pushSubscription, query: pushSubscriptionQuery, in: DirectExecutor()))
        }
    }
}
