//
//  GetConfigNetworkDataSource.swift
//  MagicBell
//
//  Created by Javi on 16/11/21.
//

import Foundation
import Harmony

public class ConfigNetworkDataSource: GetDataSource {

    public typealias T = Config

    private let httpClient: HttpClient
    private let mapper: Mapper<Data, Config>

    public init(httpClient: HttpClient, mapper: Mapper<Data, Config>) {
        self.httpClient = httpClient
        self.mapper = mapper
    }

    public func get(_ query: Query) -> Future<Config> {
        switch query {
        case let userQuery as UserQuery:
            let urlRequest = self.httpClient.prepareURLRequest(
                path: "/config",
                externalId: userQuery.externalId,
                email: userQuery.email
            )
            return self.httpClient
                .performRequest(urlRequest)
                .map { try self.mapper.map($0) }
        default:
            query.fatalError(.get, self)
        }
    }

    public func getAll(_ query: Query) -> Future<[Config]> {
        query.fatalError(.getAll, self)
    }
}
