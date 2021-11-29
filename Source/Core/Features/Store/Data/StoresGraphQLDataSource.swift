//
//  NotificationGraphQLDataSource.swift
//  MagicBell
//
//  Created by Javi on 25/11/21.
//

import Foundation
import Harmony

class StoresGraphQLDataSource: GetDataSource {
    public typealias T = [String: StorePage]

    private let httpClient: HttpClient
    private let mapper: DataToDecodableMapper<GraphQLResponse<StorePage>>

    public init(httpClient: HttpClient,
                mapper: DataToDecodableMapper<GraphQLResponse<StorePage>>) {
        self.httpClient = httpClient
        self.mapper = mapper
    }

    public func get(_ query: Query) -> Future<[String: StorePage]> {
        switch query {
        case let query as StoreQuery:
            var urlRequest = httpClient.prepareURLRequest(
                    path: "/graphql",
                    externalId: query.userQuery.externalId,
                    email: query.userQuery.email
            )
            urlRequest.allHTTPHeaderFields = ["content-type": "application/json"]
            urlRequest.httpMethod = "POST"
            do {
                let graphQLQuery = GraphQLRequest(
                    predicate: query,
                    fragment: GraphQLFragment(filename: "NotificationFragment")
                )
                urlRequest.httpBody = try JSONEncoder().encode(["query": graphQLQuery.graphQLValue])
            } catch {
                return Future(MappingError(className: "\(T.self)"))
            }

            return self.httpClient
                    .performRequest(urlRequest)
                    .map {
                        try self.mapper.map($0).response
                    }
        default:
            query.fatalError(.get, self)
        }
    }

    public func getAll(_ query: Query) -> Future<[[String: StorePage]]> {
        query.fatalError(.getAll, self)
    }
}
