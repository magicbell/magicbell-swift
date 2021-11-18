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
    private let urlSession: URLSession

    init(environment: Environment,
         urlSession: URLSession) {
        self.environment = environment
        self.urlSession = urlSession
    }

    func getConfigNetworkDataSource() -> AnyGetDataSource<Config> {
        configNetworkDataSource
    }

    private lazy var configNetworkDataSource = AnyGetDataSource(
            ConfigNetworkDataSource(
                    environment: environment,
                    urlSession: urlSession,
                    mapper: DataToDecodableMapper<Config>()
            )
    )
}
