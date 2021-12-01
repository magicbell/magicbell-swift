//
//  MarkNotificationAsReadInteractor.swift
//  MagicBell
//
//  Created by Javi on 30/11/21.
//

import Harmony

struct MarkNotificationAsReadInteractor {

    private let executor: Executor
    private let getUserQueryIdInteractor: GetUserQueryInteractor
    private let actionNotificationInteractor: Interactor.PutByQuery<Void>
    private let updateNotificationFromStoreChanges: UpdateStoreFromNotificationChangeInteractor

    init(executor: Executor, getUserQueryIdInteractor: GetUserQueryInteractor,
         actionNotificationInteractor: Interactor.PutByQuery<Void>,
         updateNotificationFromStoreChanges: UpdateStoreFromNotificationChangeInteractor) {
        self.executor = executor
        self.getUserQueryIdInteractor = getUserQueryIdInteractor
        self.actionNotificationInteractor = actionNotificationInteractor
        self.updateNotificationFromStoreChanges = updateNotificationFromStoreChanges
    }

    func execute(notification: Notification, in executor: Executor? = nil) -> Future<Notification> {
        let exec = (executor ?? self.executor)
        return exec.submit { resolver in
            let userQuery = try getUserQueryIdInteractor.executeSync()

            _ = try actionNotificationInteractor.execute(
                Void(),
                query: NotificationActionQuery(action: .markAsRead, notificationId: notification.id, userQuery: userQuery),
                in: DirectExecutor()
            ).result.get()

            var tempNotification = notification
            let date = Date()
            tempNotification.readAt = date
            tempNotification.seenAt = date

//            try updateNotificationFromStoreChanges.execute(newNotification: tempNotification, in: DirectExecutor()).result.get()

            resolver.set(tempNotification)
        }
    }
}
