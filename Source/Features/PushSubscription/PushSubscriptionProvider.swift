//
//  PushSubscriptionProvider.swift
//  MagicBell
//
//  Created by Javi on 18/11/21.
//

import Foundation
import Harmony

protocol PushSubscriptionComponent {
    func getDeletePushSubscriptionInteractor() -> DeletePushSubscriptionInteractor
    func getSaveDeviceTokenInteractor() -> SaveDeviceTokenInteractor
    func getSendPushSubscriptionInteractor() -> SendPushSubscriptionInteractor
}

class DefaultPushSubscriptionModule: PushSubscriptionComponent {

    private let userQueryComponent: UserQueryComponent
    private let httpClient: HttpClient
    private let executor: Executor
    private let logger: Logger
    
    init(
        userQueryComponent: UserQueryComponent,
        httpClient: HttpClient,
        executor: Executor,
        logger: Logger
    ) {
        self.userQueryComponent = userQueryComponent
        self.httpClient = httpClient
        self.executor = executor
        self.logger = logger
    }

    func getSendPushSubscriptionInteractor() -> SendPushSubscriptionInteractor {
        SendPushSubscriptionInteractor(
            executor: executor,
            getUserQueryInteractor: userQueryComponent.getUserQueryInteractor(),
            getDeviceTokenInteractor: getDeviceTokenInteractor,
            putPushSubscriptionInteractor: putPushSubscriptionInteractor,
            logger: logger
        )
    }

    // MARK: - Push subscription

    private var putPushSubscriptionInteractor: Interactor.PutByQuery<PushSubscription> {
        pushSubscritionRepository.toPutByQueryInteractor(executor)
    }
    
    func getDeletePushSubscriptionInteractor() -> DeletePushSubscriptionInteractor {
        DeletePushSubscriptionInteractor(
            executor: executor,
            getUserQueryInteractor: userQueryComponent.getUserQueryInteractor(),
            getDeviceTokenInteractor: getDeviceTokenInteractor,
            deletePushSubscriptionInteractor: pushSubscritionRepository.toDeleteByQueryInteractor(executor),
            logger: logger
        )
    }

    private lazy var pushSubscritionRepository: AnyRepository<PushSubscription> = {
        let pushSubscriptionNetworkDataSource = PushSubscriptionNetworkDataSource(
            httpClient: httpClient,
            mapper: DataToDecodableMapper<PushSubscription>()
        )
        let assemblePushSubscriptionDataSource = DataSourceAssembler(put: pushSubscriptionNetworkDataSource, delete: pushSubscriptionNetworkDataSource)
        return AnyRepository(SingleDataSourceRepository(assemblePushSubscriptionDataSource))
    }()

    // MARK: - Device token

    private lazy var deviceTokenInMemoryRepository = SingleDataSourceRepository(InMemoryDataSource<String>())

    func getSaveDeviceTokenInteractor() -> SaveDeviceTokenInteractor {
        SaveDeviceTokenInteractor(saveDeviceTokenInteractor: deviceTokenInMemoryRepository.toPutByQueryInteractor(executor))
    }

    private var getDeviceTokenInteractor: Interactor.GetByQuery<String> {
        deviceTokenInMemoryRepository.toGetByQueryInteractor(executor)
    }
}
