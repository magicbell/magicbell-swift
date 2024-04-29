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

protocol APNSTokenComponent {
    func apnsTokenDirector(with userQuery: UserQuery) -> APNSTokenDirector
}

class DefaultAPNSTokenModule: APNSTokenComponent {

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

    func apnsTokenDirector(with userQuery: UserQuery) -> APNSTokenDirector {
        DefaultAPNSTokenDirector(
            logger: logger,
            userQuery: userQuery,
            registerAPNSTokenInteractor: getRegisterAPNSTokenInteractor(),
            deleteAPNSTokenInteractor: getDeleteAPNSTokenInteractor()
        )
    }

    // MARK: - APNS Token

    private func getRegisterAPNSTokenInteractor() -> RegisterAPNSTokenInteractor {
        RegisterAPNSTokenInteractor(
            executor: executor,
            registerAPNSTokenInteractor: putAPNSTokenInteractor,
            logger: logger
        )
    }

    
    private func getDeleteAPNSTokenInteractor() -> DeleteAPNSTokenInteractor {
        DeleteAPNSTokenInteractor(
            executor: executor,
            deleteAPNSTokenInteractor: deleteAPNSTokenInteractor,
            logger: logger
        )
    }
    
    private var putAPNSTokenInteractor: Interactor.PutByQuery<APNSToken> {
        apnsTokenRepository.toPutByQueryInteractor(executor)
    }
    
    private var deleteAPNSTokenInteractor: Interactor.DeleteByQuery {
        apnsTokenRepository.toDeleteByQueryInteractor(executor)
    }
    
    private lazy var apnsTokenRepository: AnyRepository<APNSToken> = {
        let apnsTokenNetworkDataSource = APNSTokenNetworkDataSource(
            httpClient: httpClient,
            mapper: DataToDecodableMapper<APNSToken>()
        )
        let assembleAPNSTokenNetworkDataSource = DataSourceAssembler(put: apnsTokenNetworkDataSource,
                                                                     delete: apnsTokenNetworkDataSource)
        return AnyRepository(SingleDataSourceRepository(assembleAPNSTokenNetworkDataSource))
    }()
}
