//
//  NotificationProvider.swift
//  MagicBell
//
//  Created by Javi on 18/11/21.
//

import Foundation
import Harmony

protocol NotificationComponent {
    func getNotificationInteractor() -> GetNotificationInteractor
    func getActionNotificationInteractor() -> ActionNotificationInteractor
    func getDeleteNotificationInteractor() -> DeleteNotificationInteractor
}

class DefaultNotificationComponent: NotificationComponent {

    private let httpClient: HttpClient
    private let executor: Executor
    private let userComponent: UserComponent

    init(httpClient: HttpClient,
         executor: Executor,
         userComponent: UserComponent) {
        self.httpClient = httpClient
        self.executor = executor
        self.userComponent = userComponent
    }


    func getNotificationInteractor() -> GetNotificationInteractor {
        let getNotificationInteractor = notificationNetworkDataSource.toGetRepository().toGetByQueryInteractor(executor)
        return GetNotificationInteractor(executor: executor,
                                         getUserQueryInteractor: userComponent.getUserQueryInteractor(),
                                         getInteractor: getNotificationInteractor)
    }

    func getActionNotificationInteractor() -> ActionNotificationInteractor {
        return ActionNotificationInteractor(executor: executor,
                                            getUserQueryInteractor: userComponent.getUserQueryInteractor(),
                                            actionInteractor: actionNotificationNetworkDataSource.toPutRepository().toPutByQueryInteractor(executor))
    }

    private lazy var notificationNetworkDataSource = NotificationNetworkDataSource(
        httpClient: httpClient,
        mapper: DataToDecodableMapper<Notification>()
    )

    private lazy var actionNotificationNetworkDataSource = ActionNotificationNetworkDataSource(
        httpClient: httpClient
    )

    func getDeleteNotificationInteractor() -> DeleteNotificationInteractor {
        let deleteNotificationInteractor = actionNotificationNetworkDataSource.toDeleteRepository().toDeleteByQueryInteractor(executor)
        return DeleteNotificationInteractor(executor: executor,
                                            getUserQueryInteractor: userComponent.getUserQueryInteractor(),
                                            deleteInteractor: deleteNotificationInteractor)
    }
}
