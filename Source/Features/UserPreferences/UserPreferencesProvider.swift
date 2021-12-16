//
//  UserPreferencesProvider.swift
//  MagicBell
//
//  Created by Javi on 17/11/21.
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
