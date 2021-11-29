//
//  StoreProvider.swift
//  MagicBell
//
//  Created by Javi on 25/11/21.
//

import Foundation
import Harmony

public protocol StoreComponent {
    func getStorePagesInteractor() -> GetStorePagesInteractor
}

class DefaultStoreModule: StoreComponent {

    private let httpClient: HttpClient
    private let mainExecutor: Executor

    init(httpClient: HttpClient,
         executor: Executor) {
        self.httpClient = httpClient
        self.mainExecutor = executor
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
}
