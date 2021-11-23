//
//  UserProvider.swift
//  MagicBell
//
//  Created by Javi on 23/11/21.
//

import Foundation
import Harmony

public protocol UserComponent {
    func getUserConfigInteractor() -> GetUserConfigInteractor
    func deleteUserConfigInteractor() -> DeleteUserConfigInteractor
}

class DefaultUserComponent: UserComponent {

    private let configComponent: ConfigComponent
    private let executor: Executor

    init(configComponent: ConfigComponent,
         executor: Executor) {
        self.configComponent = configComponent
        self.executor = executor
    }

    func getUserConfigInteractor() -> GetUserConfigInteractor {
        return GetUserConfigInteractor(userConfigRepository.toGetByQueryInteractor(executor))
    }

    func deleteUserConfigInteractor() -> DeleteUserConfigInteractor {
        return DeleteUserConfigInteractor(userConfigRepository.toDeleteAllByQueryInteractor(executor))
    }

    private lazy var userConfigRepository: AnyRepository<Config> = {
        let configDataSourceAssembler = DataSourceAssembler(get: configComponent.getConfigNetworkDataSource())

        let configDeviceStorageDataSource = DeviceStorageDataSource<Data>(prefix: "magicbell")
        let configStorage = DataSourceMapper(dataSource: configDeviceStorageDataSource,
                                             toInMapper: EncodableToDataMapper<Config>(),
                                             toOutMapper: DataToDecodableMapper<Config>())

        return AnyRepository(CacheRepository(main: configDataSourceAssembler, cache: configStorage))
    }()
}
