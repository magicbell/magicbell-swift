//
//  NotificationGraphQLDataSource.swift
//  MagicBell
//
//  Created by Javi on 25/11/21.
//

import Foundation
import Harmony

class StoresGraphQLDataSource: GetDataSource {
    public typealias T = Stores

    private let httpClient: HttpClient
    private let mapper: DataToDecodableMapper<Stores>

    public init(httpClient: HttpClient,
                mapper: DataToDecodableMapper<Stores>) {
        self.httpClient = httpClient
        self.mapper = mapper
    }

    public func get(_ query: Query) -> Future<Stores> {
        switch query {
        case let notificationQuery as NotificationStoreQuery:
            var urlRequest = httpClient.prepareURLRequest(
                    path: "/graphql",
                    externalId: notificationQuery.user.externalId,
                    email: notificationQuery.user.email
            )
            urlRequest.allHTTPHeaderFields = ["content-type": "application/json"]
            urlRequest.httpMethod = "POST"
            do {
                let graphQLQuery = StoreGraphQLQueryBuilder(storeContext: notificationQuery.storeContext)
                urlRequest.httpBody = try JSONEncoder().encode(["query": graphQLQuery.graphQLQuery])
            } catch {
                return Future(MappingError(className: "\(T.self)"))
            }

            return self.httpClient
                    .performRequest(urlRequest)
                    .map {
                        try self.mapper.map($0)
                    }
        default:
            query.fatalError(.get, self)
        }
    }

    public func getAll(_ query: Query) -> Future<[Stores]> {
        query.fatalError(.getAll, self)
    }
}
