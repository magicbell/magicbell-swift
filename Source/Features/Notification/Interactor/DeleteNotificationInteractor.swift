//
//  DeleteNotificationInteractor.swift
//  MagicBell
//
//  Created by Javi on 2/12/21.
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
