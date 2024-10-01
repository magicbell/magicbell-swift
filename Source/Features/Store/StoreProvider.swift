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

protocol StoreComponent {
    func storeDirector(with userQuery: UserQuery) -> InternalStoreDirector
}

class DefaultStoreModule: StoreComponent {
    private let httpClient: HttpClient
    private let mainExecutor: Executor
    private let notificationComponent: NotificationComponent
    private let realTimeComponent: StoreRealTimeComponent
    private let configComponent: ConfigComponent
    private let logger: Logger

    init(httpClient: HttpClient,
         executor: Executor,
         notificationComponent: NotificationComponent,
         storeRealTimeComponent: StoreRealTimeComponent,
         configComponent: ConfigComponent,
         logger: Logger) {
        self.httpClient = httpClient
        self.mainExecutor = executor
        self.notificationComponent = notificationComponent
        self.realTimeComponent = storeRealTimeComponent
        self.configComponent = configComponent
        self.logger = logger
    }

    private lazy var storeNotificationGraphQLRepository: AnyGetRepository<StorePage> = {
        AnyGetRepository(
            SingleGetDataSourceRepository(
                StoreDataSource(
                    httpClient: httpClient,
                    mapper: DataToDecodableMapper<StorePage>()
                )
            )
        )
    }()

    private func getStorePagesInteractor() -> GetStorePagesInteractor {
        GetStorePagesInteractor(
            executor: mainExecutor,
            getStoreNotificationInteractor: storeNotificationGraphQLRepository.toGetByQueryInteractor(mainExecutor))
    }

    private func getFetchStorePageInteractor() -> FetchStorePageInteractor {
        FetchStorePageDefaultInteractor(
            executor: mainExecutor,
            getStorePagesInteractor: getStorePagesInteractor()
        )
    }

    func storeDirector(with userQuery: UserQuery) -> InternalStoreDirector {
        RealTimeByPredicateStoreDirector(
            logger: logger,
            userQuery: userQuery,
            fetchStorePageInteractor: getFetchStorePageInteractor(),
            actionNotificationInteractor: notificationComponent.getActionNotificationInteractor(),
            deleteNotificationInteractor: notificationComponent.getDeleteNotificationInteractor(),
            getConfigInteractor: configComponent.getGetConfigInteractor(),
            deleteConfigInteractor: configComponent.getDeleteConfigInteractor(),
            storeRealTime: realTimeComponent.createStoreRealmTime(userQuery: userQuery)
        )
    }
}
