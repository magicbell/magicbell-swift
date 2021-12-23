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
