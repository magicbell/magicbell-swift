//
//  ConfigProvider.swift
//  MagicBell
//
//  Created by Javi on 16/11/21.
//

import Foundation
import Harmony

protocol ConfigComponent {
    func getConfigNetworkDataSource() -> AnyGetDataSource<Config>
}

class DefaultConfigModule: ConfigComponent {
    private let environment: Environment
    private let httpClient: HttpClient

    init(environment: Environment,
         httpClient: HttpClient) {
        self.environment = environment
        self.httpClient = httpClient
    }

    func getConfigNetworkDataSource() -> AnyGetDataSource<Config> {
        configNetworkDataSource
    }

    private lazy var configNetworkDataSource = AnyGetDataSource(
            ConfigNetworkDataSource(
                    environment: environment,
                    httpClient: httpClient,
                    mapper: DataToDecodableMapper<Config>()
            )
    )
}
