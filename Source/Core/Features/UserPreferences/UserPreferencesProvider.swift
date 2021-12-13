//
//  UserPreferencesProvider.swift
//  MagicBell
//
//  Created by Javi on 17/11/21.
//

import Foundation
import Harmony

protocol UserPreferencesComponent {
    func getGetUserPreferencesInteractor() -> GetUserPreferencesInteractor
    func getUpdateUserPreferencesInteractor() -> UpdateUserPreferencesInteractor
}

class DefaultUserPreferencesModule: UserPreferencesComponent {
    private let httpClient: HttpClient
    private let executor: Executor
    private let userQueryComponent: UserQueryComponent

    init(
        httpClient: HttpClient,
        executor: Executor,
        userQueryComponent: UserQueryComponent
    ) {
        self.userQueryComponent = userQueryComponent
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

    func getGetUserPreferencesInteractor() -> GetUserPreferencesInteractor {
        return GetUserPreferencesInteractor(
            executor: executor,
            getUserQueryInteractor: userQueryComponent.getUserQueryInteractor(),
            getUserPreferencesInteractor: userPreferencesRepository.toGetByQueryInteractor(executor)
        )
    }

    func getUpdateUserPreferencesInteractor() -> UpdateUserPreferencesInteractor {
        return UpdateUserPreferencesInteractor(
            executor: executor,
            getUserQueryInteractor: userQueryComponent.getUserQueryInteractor(),
            updateUserPreferencesInteractor: userPreferencesRepository.toPutByQueryInteractor(executor)
        )
    }
}
