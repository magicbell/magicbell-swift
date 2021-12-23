//
// By downloading or using this software made available by MagicBell, Inc.
// ("MagicBell") or any documentation that accompanies it (collectively, the
// "Software"), you and the company or entity that you represent (collectively,
// "you" or "your") are consenting to be bound by and are becoming a party to this
// License Agreement (this "Agreement"). You hereby represent and warrant that you
// are authorized and lawfully able to bind such company or entity that you
// represent to this Agreement.  If you do not have such authority or do not agree
// to all of the terms of this Agreement, you may not download or use the Software.
//
// For more information, read the LICENSE file.
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
        ActionNotificationDefaultInteractor(
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
        return DeleteNotificationDefaultInteractor(
            executor: executor,
            deleteInteractor: deleteNotificationInteractor
        )
    }
}
