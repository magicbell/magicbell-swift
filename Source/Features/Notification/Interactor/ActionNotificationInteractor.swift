//
//  ActionNotificationInteractor.swift
//  MagicBell
//
//  Created by Javi on 2/12/21.
//

import Harmony

struct ActionNotificationInteractor {

    private let executor: Executor
    private let actionInteractor: Interactor.PutByQuery<Void>

    init(executor: Executor,
         actionInteractor: Interactor.PutByQuery<Void>) {
        self.executor = executor
        self.actionInteractor = actionInteractor
    }

    func execute(action: NotificationActionQuery.Action,
                 userQuery: UserQuery,
                 notificationId: String? = nil) -> Future<Void> {
        return executor.submit {
            let query = NotificationActionQuery(action: action, notificationId: notificationId ?? "", userQuery: userQuery)
            try actionInteractor.execute(nil, query: query, in: DirectExecutor()).result.get()
        }
    }
}
