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

protocol DeleteNotificationInteractor {
    func execute(notificationId: String, userQuery: UserQuery) -> Future <Void>
}

struct DeleteNotificationDefaultInteractor: DeleteNotificationInteractor {

    private let executor: Executor
    private let deleteInteractor: Interactor.DeleteByQuery

    init(executor: Executor,
         deleteInteractor: Interactor.DeleteByQuery) {
        self.executor = executor
        self.deleteInteractor = deleteInteractor
    }

    func execute(notificationId: String, userQuery: UserQuery) -> Future <Void> {
        executor.submit {
            let query = NotificationQuery(notificationId: notificationId, userQuery: userQuery)
            try deleteInteractor.execute(query, in: DirectExecutor()).result.get()
        }
    }
}
