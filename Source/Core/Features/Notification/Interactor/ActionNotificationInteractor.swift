//
//  ActionNotificationInteractor.swift
//  MagicBell
//
//  Created by Javi on 2/12/21.
//

import Harmony

struct ActionNotificationInteractor {

    private let executor: Executor
    private let getUserQueryInteractor: GetUserQueryInteractor
    private let actionInteractor: Interactor.PutByQuery<Void>

    init(executor: Executor,
         getUserQueryInteractor: GetUserQueryInteractor,
         actionInteractor: Interactor.PutByQuery<Void>) {
        self.executor = executor
        self.getUserQueryInteractor = getUserQueryInteractor
        self.actionInteractor = actionInteractor
    }

    func execute(action: NotificationActionQuery.Action,
                 notificationId: String? = nil) -> Future<Void> {
        return executor.submit { resolver in
            let userQuery = try getUserQueryInteractor.execute()
            resolver.set(actionInteractor.execute(nil,
                                                  query: NotificationActionQuery(action: action, notificationId: notificationId ?? "", userQuery: userQuery),
                                                  in: DirectExecutor()))
        }
    }
}
