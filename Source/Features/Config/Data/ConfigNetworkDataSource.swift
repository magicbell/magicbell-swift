//
//  GetConfigNetworkDataSource.swift
//  MagicBell
//
//  Created by Javi on 16/11/21.
//

import Foundation
import Harmony

class ConfigNetworkDataSource: GetDataSource {

    typealias T = Config

    private let httpClient: HttpClient
    private let mapper: Mapper<Data, Config>

    init(httpClient: HttpClient, mapper: Mapper<Data, Config>) {
        self.httpClient = httpClient
        self.mapper = mapper
    }

    func get(_ query: Query) -> Future<Config> {
        switch query {
        case let userQuery as UserQuery:
            let urlRequest = httpClient.prepareURLRequest(
                path: "/config",
                externalId: userQuery.externalId,
                email: userQuery.email
            )
            return httpClient
                .performRequest(urlRequest)
                .map { try self.mapper.map($0) }
        default:
            assertionFailure("Should never happen")
            return Future(CoreError.NotImplemented())
        }
    }

    func getAll(_ query: Query) -> Future<[Config]> {
        assertionFailure("Should never happen")
        return Future(CoreError.NotImplemented())
    }
}
