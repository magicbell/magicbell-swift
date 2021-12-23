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

protocol UserPreferencesComponent {
    func userPreferencesDirector(with userQuery: UserQuery) -> UserPreferencesDirector
}

class DefaultUserPreferencesModule: UserPreferencesComponent {

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

    private lazy var userPreferencesRepository: AnyRepository<UserPreferences> = {
        let userPreferencesNetworkDataSource = UserPreferencesNetworkDataSource(
            httpClient: httpClient,
            mapper: DataToDecodableMapper<UserPreferencesEntity>()
        )

        let userPreferencesAssemblerDataSource = DataSourceAssembler(get: userPreferencesNetworkDataSource, put: userPreferencesNetworkDataSource)
        let repository = SingleDataSourceRepository(userPreferencesAssemblerDataSource)
        let repositoryMapper = RepositoryMapper(
            repository: repository,
            toInMapper: UserPreferencesToUserPreferencesEntityMapper(),
            toOutMapper: UserPreferencesEntityToUserPreferencesMapper()
        )
        return AnyRepository(repositoryMapper)
    }()

    private func getGetUserPreferencesInteractor() -> GetUserPreferencesInteractor {
        return GetUserPreferencesInteractor(
            executor: executor,
            getUserPreferencesInteractor: userPreferencesRepository.toGetByQueryInteractor(executor)
        )
    }

    private func getUpdateUserPreferencesInteractor() -> UpdateUserPreferencesInteractor {
        return UpdateUserPreferencesInteractor(
            executor: executor,
            updateUserPreferencesInteractor: userPreferencesRepository.toPutByQueryInteractor(executor)
        )
    }

    func userPreferencesDirector(with userQuery: UserQuery) -> UserPreferencesDirector {
        DefaultUserPreferencesDirector(
            logger: logger,
            userQuery: userQuery,
            getUserPreferencesInteractor: getGetUserPreferencesInteractor(), updateUserPreferencesInteractor: getUpdateUserPreferencesInteractor()
        )
    }
}
