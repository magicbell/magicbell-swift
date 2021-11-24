//
//  UserProvider.swift
//  MagicBell
//
//  Created by Javi on 23/11/21.
//

import Foundation
import Harmony

protocol UserComponent {
    func getLoginInteractor() -> LoginInteractor
    func getLogoutInteractor() -> LogoutInteractor
    func getUserQueryInteractor() -> GetUserQueryInteractor
}

class DefaultUserComponent: UserComponent {

    private let logger: Logger
    private let configComponent: ConfigComponent
    private let executor: Executor

    init(logger: Logger,
         configComponent: ConfigComponent,
         executor: Executor
    ) {
        self.logger = logger
        self.configComponent = configComponent
        self.executor = executor
    }

    private lazy var userConfigRepository: AnyRepository<Config> = {
        let configDataSourceAssembler = DataSourceAssembler(get: configComponent.getConfigNetworkDataSource())

        let configDeviceStorageDataSource = DeviceStorageDataSource<Data>(prefix: "magicbell")
        let configStorage = DataSourceMapper(dataSource: configDeviceStorageDataSource,
                                             toInMapper: EncodableToDataMapper<Config>(),
                                             toOutMapper: DataToDecodableMapper<Config>())

        return AnyRepository(CacheRepository(main: configDataSourceAssembler, cache: configStorage))
    }()

    private lazy var userQueryStorageRepository = SingleDataSourceRepository(InMemoryDataSource<UserQuery>())

    func getLoginInteractor() -> LoginInteractor {
        let storeUserQuery = StoreUserQueryInteractor(
            storeUserQuery: userQueryStorageRepository.toPutByQueryInteractor(executor)
        )

        return LoginInteractor(
            logger: logger,
            getUserConfig: GetUserConfigInteractor(
                userConfigRepository.toGetByQueryInteractor(executor)
            ),
            storeUserQuery: storeUserQuery
        )
    }

    func getLogoutInteractor() -> LogoutInteractor {
        let deleteUserQuery = DeleteUserQueryInteractor(
            deleteUserQuery: userQueryStorageRepository.toDeleteByQueryInteractor(executor)
        )
        return LogoutInteractor(
            logger: logger,
            deleteUserConfig: DeleteUserConfigInteractor(
                userConfigRepository.toDeleteAllByQueryInteractor(executor)
            ),
            deleteUserQuery: deleteUserQuery
        )
    }

    func getUserQueryInteractor() -> GetUserQueryInteractor {
        return GetUserQueryInteractor(
            getUserQuery: userQueryStorageRepository.toGetByQueryInteractor(executor)
        )
    }
}
