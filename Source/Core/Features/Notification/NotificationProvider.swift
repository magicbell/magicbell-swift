//
//  NotificationProvider.swift
//  MagicBell
//
//  Created by Javi on 18/11/21.
//

import Foundation
import Harmony

protocol NotificationComponent {
    func getNotificationNetworkDataSource() -> AnyGetDataSource<Notification>
    func getActionNotificationNetworkDataSource() -> AnyPutDataSource<Void>
    func getDeleteNotificationNetworkDataSource() -> DeleteDataSource
}

class DefaultNotificationComponent: NotificationComponent {
    private let environment: Environment
    private let httpClient: HttpClient

    init(environment: Environment, httpClient: HttpClient) {
        self.environment = environment
        self.httpClient = httpClient
    }

    private lazy var notificationNetworkDataSource = NotificationNetworkDataSource(
            environment: environment,
            httpClient: httpClient,
            mapper: DataToDecodableMapper<Notification>()
    )

    private lazy var actionNotificationNetworkDataSource = ActionNotificationNetworkDataSource(
            environment: environment,
            httpClient: httpClient
    )

    func getNotificationNetworkDataSource() -> AnyGetDataSource<Notification> {
        AnyGetDataSource(notificationNetworkDataSource)
    }

    func getActionNotificationNetworkDataSource() -> AnyPutDataSource<Void> {
        AnyPutDataSource(actionNotificationNetworkDataSource)
    }

    func getDeleteNotificationNetworkDataSource() -> DeleteDataSource {
        actionNotificationNetworkDataSource
    }
}
