//
//  StoreProvider.swift
//  MagicBell
//
//  Created by Javi on 25/11/21.
//

import Foundation
import Harmony

public protocol StoreComponent {
    func getNotificationStoreInteractor() -> Interactor.GetByQuery<Stores>
}

class DefaultStoreModule: StoreComponent {

    private let httpClient: HttpClient
    private let mainExecutor: Executor

    init(httpClient: HttpClient,
         executor: Executor) {
        self.httpClient = httpClient
        self.mainExecutor = executor
    }

    func getNotificationStoreInteractor() -> Interactor.GetByQuery<Stores> {
        storeNotificationGraphQLRepository.toGetByQueryInteractor(mainExecutor)
    }

    private lazy var storeNotificationGraphQLRepository: AnyGetRepository<Stores> = {
        AnyGetRepository(SingleGetDataSourceRepository(StoresGraphQLDataSource(httpClient: httpClient, mapper: DataToDecodableMapper<Stores>(iso8601: true))))
    }()
}
