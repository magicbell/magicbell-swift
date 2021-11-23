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
    func getActionNotificationNetworkDataSource() -> AnyPutDataSource<Void>
    func getDeleteNotificationNetworkDataSource() -> DeleteDataSource
}

class DefaultNotificationComponent: NotificationComponent {
    private let httpClient: HttpClient

    init(httpClient: HttpClient) {
        self.httpClient = httpClient
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

    func getActionNotificationNetworkDataSource() -> AnyPutDataSource<Void> {
        AnyPutDataSource(actionNotificationNetworkDataSource)
    }

    func getDeleteNotificationNetworkDataSource() -> DeleteDataSource {
        actionNotificationNetworkDataSource
    }
}
