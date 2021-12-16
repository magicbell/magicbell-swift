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

    init(httpClient: HttpClient, executor: Executor) {
        self.httpClient = httpClient
        self.executor = executor
    }

    func getNotificationInteractor() -> GetNotificationInteractor {
        let getNotificationInteractor = notificationNetworkDataSource.toGetRepository().toGetByQueryInteractor(executor)
        return GetNotificationInteractor(
            executor: executor,
            getNotificationInteractor: getNotificationInteractor
        )
    }

    func getActionNotificationInteractor() -> ActionNotificationInteractor {
        ActionNotificationInteractor(
            executor: executor,
            actionInteractor: actionNotificationNetworkDataSource.toPutRepository().toPutByQueryInteractor(executor)
        )
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
        return DeleteNotificationInteractor(
            executor: executor,
            deleteInteractor: deleteNotificationInteractor
        )
    }
}
