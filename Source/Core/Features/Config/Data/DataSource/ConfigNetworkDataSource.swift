//
//  GetConfigNetworkDataSource.swift
//  MagicBell
//
//  Created by Javi on 16/11/21.
//

import Foundation
import Harmony
import CommonCrypto

public class ConfigNetworkDataSource {

    public typealias T = Config

    private let environment: Environment
    private let httpClient: HttpClient
    private let mapper: DataToDecodableMapper<Config>

    public init(environment: Environment,
                httpClient: HttpClient,
                mapper: DataToDecodableMapper<Config>) {
        self.environment = environment
        self.httpClient = httpClient
        self.mapper = mapper
    }
}
extension ConfigNetworkDataSource: GetDataSource {
    public func get(_ query: Query) -> Future<Config> {
        switch query {
        case let userQuery as UserQuery:
            let urlRequest = self.httpClient.prepareURLRequest(
                baseURL: environment.baseUrl,
                path: "/config",
                apiKey: environment.apiKey,
                apiSecret: environment.apiSecret,
                externalId: userQuery.externalId,
                email: userQuery.email,
                isHMACEnabled: environment.isHMACEnabled)

            return self.httpClient.performRequest(urlRequest).map { data in
                try self.mapper.map(data)
            }.recover { error in
                Future(error)
            }
        default:
            query.fatalError(.get, self)
        }
    }

    public func getAll(_ query: Query) -> Future<[Config]> {
        query.fatalError(.getAll, self)
    }
}
