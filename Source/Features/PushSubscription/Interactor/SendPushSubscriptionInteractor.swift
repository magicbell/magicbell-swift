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
