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
