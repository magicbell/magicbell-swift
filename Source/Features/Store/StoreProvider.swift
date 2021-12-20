//
//  StoreProvider.swift
//  MagicBell
//
//  Created by Javi on 25/11/21.
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

    private lazy var storeNotificationGraphQLRepository: AnyGetRepository<[String: StorePage]> = {
        AnyGetRepository(
            SingleGetDataSourceRepository(
                StoresGraphQLDataSource(
                    httpClient: httpClient,
                    mapper: DataToDecodableMapper<GraphQLResponse<StorePage>>(iso8601: true)
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
