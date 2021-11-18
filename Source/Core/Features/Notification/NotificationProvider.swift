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
    private let urlSession: URLSession

    init(environment: Environment, urlSession: URLSession) {
        self.environment = environment
        self.urlSession = urlSession
    }

    private lazy var notificationNetworkDataSource = NotificationNetworkDataSource(
            environment: environment,
            urlSession: urlSession,
            mapper: DataToDecodableMapper<Notification>()
    )

    private lazy var actionNotificationNetworkDataSource = ActionNotificationNetworkDataSource(
            environment: environment,
            urlSession: urlSession
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
