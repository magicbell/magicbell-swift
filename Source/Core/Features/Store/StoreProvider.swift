//
//  StoreProvider.swift
//  MagicBell
//
//  Created by Javi on 25/11/21.
//

import Foundation
import Harmony

protocol StoreComponent {
    func getStorePagesInteractor() -> GetStorePagesInteractor
    func createStore(name: String?, predicate: StorePredicate) -> NotificationStore
}

class DefaultStoreModule: StoreComponent {

    private let httpClient: HttpClient
    private let mainExecutor: Executor
    private let userComponent: UserComponent
    private let notificationComponent: NotificationComponent
    private let logger: Logger

    init(httpClient: HttpClient,
         executor: Executor,
         userComponent: UserComponent,
         notificationComponent: NotificationComponent,
         logger: Logger) {
        self.httpClient = httpClient
        self.mainExecutor = executor
        self.userComponent = userComponent
        self.notificationComponent = notificationComponent
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

    func getStorePagesInteractor() -> GetStorePagesInteractor {
        GetStorePagesInteractor(
            executor: mainExecutor,
            getStoreNotificationInteractor: storeNotificationGraphQLRepository.toGetByQueryInteractor(mainExecutor))
    }

    func createStore(name: String?, predicate: StorePredicate) -> NotificationStore {

        let fetchStorePageInteractor = FetchStorePageInteractor(executor: mainExecutor,
                                                                getUserQueryInteractor: userComponent.getUserQueryInteractor(),
                                                                getStorePagesInteractor: getStorePagesInteractor())

        return NotificationStore(name: name ?? UUID().uuidString,
                                 storePredicate: predicate,
                                 getUserQueryInteractor: userComponent.getUserQueryInteractor(),
                                 fetchStorePageInteractor: fetchStorePageInteractor,
                                 actionNotificationInteractor: notificationComponent.getActionNotificationInteractor(),
                                 deleteNotificationInteractor: notificationComponent.getDeleteNotificationInteractor(),
                                 logger: logger)
    }
}
