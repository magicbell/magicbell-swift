//
//  PushSubscriptionProvider.swift
//  MagicBell
//
//  Created by Javi on 18/11/21.
//

import Foundation
import Harmony

protocol PushSubscriptionComponent {
    func pushSubscriptionDirector(with userQuery: UserQuery) -> PushSubscriptionDirector
}

class DefaultPushSubscriptionModule: PushSubscriptionComponent {

    private let httpClient: HttpClient
    private let executor: Executor
    private let logger: Logger
    
    init(
        httpClient: HttpClient,
        executor: Executor,
        logger: Logger
    ) {
        self.httpClient = httpClient
        self.executor = executor
        self.logger = logger
    }

    func pushSubscriptionDirector(with userQuery: UserQuery) -> PushSubscriptionDirector {
        DefaultPushSubscriptionDirector(
            logger: logger,
            userQuery: userQuery,
            sendPushSubscriptionInteractor: getSendPushSubscriptionInteractor(),
            deletePushSubscriptionInteractor: getDeletePushSubscriptionInteractor()
        )
    }

    // MARK: - Push subscription

    private func getSendPushSubscriptionInteractor() -> SendPushSubscriptionInteractor {
        SendPushSubscriptionInteractor(
            executor: executor,
            putPushSubscriptionInteractor: putPushSubscriptionInteractor,
            logger: logger
        )
    }

    private var putPushSubscriptionInteractor: Interactor.PutByQuery<PushSubscription> {
        pushSubscritionRepository.toPutByQueryInteractor(executor)
    }
    
    private func getDeletePushSubscriptionInteractor() -> DeletePushSubscriptionInteractor {
        DeletePushSubscriptionInteractor(
            executor: executor,
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
}
