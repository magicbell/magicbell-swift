//
//  GetNotificationInteractor.swift
//  MagicBell
//
//  Created by Javi on 2/12/21.
//

import Harmony

class GetNotificationInteractor {
    private let executor: Executor
    private let getUserQueryInteractor: GetUserQueryInteractor
    private let getInteractor: Interactor.GetByQuery<Notification>

    init(executor: Executor,
         getUserQueryInteractor: GetUserQueryInteractor,
         getInteractor: Interactor.GetByQuery<Notification>) {
        self.executor = executor
        self.getUserQueryInteractor = getUserQueryInteractor
        self.getInteractor = getInteractor
    }

    func execute(notificationId: String) -> Future <Notification> {
        executor.submit { resolver in
            let userQuery = try self.getUserQueryInteractor.execute()
            resolver.set(self.getInteractor.execute(NotificationQuery(notificationId: notificationId, userQuery: userQuery), in: DirectExecutor()))
        }
    }
}
