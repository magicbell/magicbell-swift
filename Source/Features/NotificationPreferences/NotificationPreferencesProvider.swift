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

protocol NotificationPreferencesComponent {
    func notificationPreferencesDirector(with userQuery: UserQuery) -> NotificationPreferencesDirector
}

class DefaultNotificationPreferencesModule: NotificationPreferencesComponent {

    private let logger: Logger
    private let httpClient: HttpClient
    private let executor: Executor

    init(
        logger: Logger,
        httpClient: HttpClient,
        executor: Executor
    ) {
        self.logger = logger
        self.httpClient = httpClient
        self.executor = executor
    }

    private lazy var notificationPreferencesRepository: AnyRepository<NotificationPreferences> = {
        let notificationPreferencesNetworkDataSource = NotificationPreferencesNetworkDataSource(
            httpClient: httpClient,
            mapper: DataToDecodableMapper<NotificationPreferencesEntity>()
        )

        let notificationPreferencesAssemblerDataSource = DataSourceAssembler(get: notificationPreferencesNetworkDataSource, put: notificationPreferencesNetworkDataSource)
        let repository = SingleDataSourceRepository(notificationPreferencesAssemblerDataSource)
        let repositoryMapper = RepositoryMapper(
            repository: repository,
            toInMapper: NotificationPreferencesToNotificationPreferencesEntityMapper(),
            toOutMapper: NotificationPreferencesEntityToNotificationPreferencesMapper()
        )
        return AnyRepository(repositoryMapper)
    }()

    private func getGetNotificationPreferencesInteractor() -> GetNotificationPreferencesInteractor {
        return GetNotificationPreferencesInteractor(
            executor: executor,
            getNotificationPreferencesInteractor: notificationPreferencesRepository.toGetByQueryInteractor(executor)
        )
    }

    private func getUpdateNotificationPreferencesInteractor() -> UpdateNotificationPreferencesInteractor {
        return UpdateNotificationPreferencesInteractor(
            executor: executor,
            updateNotificationPreferencesInteractor: notificationPreferencesRepository.toPutByQueryInteractor(executor)
        )
    }

    func notificationPreferencesDirector(with userQuery: UserQuery) -> NotificationPreferencesDirector {
        DefaultNotificationPreferencesDirector(
            logger: logger,
            userQuery: userQuery,
            getNotificationPreferencesInteractor: getGetNotificationPreferencesInteractor(), updateNotificationPreferencesInteractor: getUpdateNotificationPreferencesInteractor()
        )
    }
}
