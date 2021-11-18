//
//  GetConfigNetworkDataSource.swift
//  MagicBell
//
//  Created by Javi on 16/11/21.
//

import Foundation
import Harmony
import CommonCrypto

public class ConfigNetworkDataSource: MagicBellNetworkDataSource<Config>, GetDataSource {

    public typealias T = Config

    private let environment: Environment

    public init(environment: Environment,
                urlSession: URLSession,
                mapper: DataToDecodableMapper<Config>) {
        self.environment = environment
        super.init(urlSession: urlSession, mapper: mapper)
    }

    public func get(_ query: Query) -> Future<Config> {
        switch query {
        case let userQuery as UserQuery:
            let urlRequest = prepareURLRequest(
                    baseURL: environment.baseUrl,
                    path: "/config",
                    apiKey: environment.apiKey,
                    apiSecret: environment.apiSecret,
                    externalId: userQuery.externalId,
                    email: userQuery.email,
                    isHMACEnabled: environment.isHMACEnabled)

            return performRequest(urlRequest)
        default:
            query.fatalError(.get, self)
        }
    }

    public func getAll(_ query: Query) -> Future<[Config]> {
        query.fatalError(.getAll, self)
    }
}
