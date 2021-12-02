//
//  DeleteNotificationInteractor.swift
//  MagicBell
//
//  Created by Javi on 2/12/21.
//

import Harmony

struct DeleteNotificationInteractor {

    private let executor: Executor
    private let getUserQueryInteractor: GetUserQueryInteractor
    private let deleteInteractor: Interactor.DeleteByQuery

    init(executor: Executor,
         getUserQueryInteractor: GetUserQueryInteractor,
         deleteInteractor: Interactor.DeleteByQuery) {
        self.executor = executor
        self.getUserQueryInteractor = getUserQueryInteractor
        self.deleteInteractor = deleteInteractor
    }

    func execute(notificationId: String) -> Future <Void> {
        executor.submit { resolver in
            let userQuery = try getUserQueryInteractor.execute()
            resolver.set(deleteInteractor.execute(NotificationQuery(notificationId: notificationId, userQuery: userQuery), in: DirectExecutor()))
        }
    }
}
