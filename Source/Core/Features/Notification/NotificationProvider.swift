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

public class DefaultNotificationComponent: NotificationComponent {
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

    public func getNotificationNetworkDataSource() -> AnyGetDataSource<Notification> {
        AnyGetDataSource(notificationNetworkDataSource)
    }

    public func getActionNotificationNetworkDataSource() -> AnyPutDataSource<Void> {
        AnyPutDataSource(actionNotificationNetworkDataSource)
    }

    public func getDeleteNotificationNetworkDataSource() -> DeleteDataSource {
        actionNotificationNetworkDataSource
    }
}
