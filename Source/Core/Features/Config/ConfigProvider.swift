//
//  ConfigProvider.swift
//  MagicBell
//
//  Created by Javi on 16/11/21.
//

import Foundation
import Harmony

protocol ConfigComponent {
    func getGetConfigInteractor() -> GetConfigInteractor
    func getDeleteConfigInteractor() -> DeleteConfigInteractor
}

class DefaultConfigModule: ConfigComponent {
    private let httpClient: HttpClient
    private let executor: Executor
    
    init(httpClient: HttpClient,
         executor: Executor) {
        self.httpClient = httpClient
        self.executor = executor
    }

    private lazy var userConfigRepository: AnyRepository<Config> = {
        let configNetworkDataSource = ConfigNetworkDataSource(
            httpClient: httpClient,
            mapper: DataToDecodableMapper<Config>()
        )
        let configDataSourceAssembler = DataSourceAssembler(get: configNetworkDataSource)

        let configDeviceStorageDataSource = DeviceStorageDataSource<Data>(prefix: "magicbell")
        let configStorage = DataSourceMapper(dataSource: configDeviceStorageDataSource,
                                             toInMapper: EncodableToDataMapper<Config>(),
                                             toOutMapper: DataToDecodableMapper<Config>())
        return AnyRepository(CacheRepository(main: configDataSourceAssembler, cache: configStorage))
    }()

    func getGetConfigInteractor() -> GetConfigInteractor {
        GetConfigInteractor(userConfigRepository.toGetByQueryInteractor(executor))
    }

    func getDeleteConfigInteractor() -> DeleteConfigInteractor {
        DeleteConfigInteractor(userConfigRepository.toDeleteAllByQueryInteractor(executor))
    }
}
