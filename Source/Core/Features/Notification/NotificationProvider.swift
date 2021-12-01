//
//  NotificationProvider.swift
//  MagicBell
//
//  Created by Javi on 18/11/21.
//

import Foundation
import Harmony

public protocol NotificationComponent {
    func getNotificationNetworkDataSource() -> AnyGetDataSource<Notification>
    func getActionNotificationInteractor() -> Interactor.PutByQuery<Void>
    func getDeleteNotificationNetworkDataSource() -> DeleteDataSource
}

class DefaultNotificationComponent: NotificationComponent {
    private let httpClient: HttpClient
    private let executor: Executor

    init(httpClient: HttpClient,
         executor: Executor) {
        self.httpClient = httpClient
        self.executor = executor
    }

    func getActionNotificationInteractor() -> Interactor.PutByQuery<Void> {
        actionNotificationNetworkDataSource.toPutRepository().toPutByQueryInteractor(executor)
    }

    private lazy var notificationNetworkDataSource = NotificationNetworkDataSource(
        httpClient: httpClient,
        mapper: DataToDecodableMapper<Notification>()
    )

    private lazy var actionNotificationNetworkDataSource = ActionNotificationNetworkDataSource(
        httpClient: httpClient
    )

    func getNotificationNetworkDataSource() -> AnyGetDataSource<Notification> {
        AnyGetDataSource(notificationNetworkDataSource)
    }

    func getDeleteNotificationNetworkDataSource() -> DeleteDataSource {
        actionNotificationNetworkDataSource
    }
}
