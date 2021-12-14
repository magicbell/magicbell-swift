//
//  GetNotificationInteractor.swift
//  MagicBell
//
//  Created by Javi on 2/12/21.
//

import Harmony

class GetNotificationInteractor {
    private let executor: Executor
    private let getNotificationInteractor: Interactor.GetByQuery<Notification>

    init(executor: Executor,
         getNotificationInteractor: Interactor.GetByQuery<Notification>) {
        self.executor = executor
        self.getNotificationInteractor = getNotificationInteractor
    }

    func execute(notificationId: String, userQuery: UserQuery) -> Future <Notification> {
        executor.submit { resolver in
            let query = NotificationQuery(notificationId: notificationId, userQuery: userQuery)
            let notification = try self.getNotificationInteractor.execute(query, in: DirectExecutor()).result.get()
            resolver.set(notification)
        }
    }
}
