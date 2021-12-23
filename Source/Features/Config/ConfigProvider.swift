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
        GetConfigDefaultInteractor(userConfigRepository.toGetByQueryInteractor(executor))
    }

    func getDeleteConfigInteractor() -> DeleteConfigInteractor {
        DeleteConfigDefaultInteractor(userConfigRepository.toDeleteAllByQueryInteractor(executor))
    }
}
