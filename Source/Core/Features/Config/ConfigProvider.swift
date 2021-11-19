//
//  ConfigProvider.swift
//  MagicBell
//
//  Created by Javi on 16/11/21.
//

import Foundation
import Harmony

public protocol ConfigComponent {
    func getConfigNetworkDataSource() -> AnyGetDataSource<Config>
}

public class DefaultConfigModule: ConfigComponent {
    private let httpClient: HttpClient
    
    init(httpClient: HttpClient) {
        self.httpClient = httpClient
    }
    
    public func getConfigNetworkDataSource() -> AnyGetDataSource<Config> {
        configNetworkDataSource
    }
    
    private lazy var configNetworkDataSource = AnyGetDataSource(
        ConfigNetworkDataSource(
            httpClient: httpClient,
            mapper: DataToDecodableMapper<Config>()
        )
    )
}
