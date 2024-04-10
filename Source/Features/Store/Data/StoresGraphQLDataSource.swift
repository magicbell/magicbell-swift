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

class StoresGraphQLDataSource: GetDataSource {
    typealias T = [String: StorePage]

    private let httpClient: HttpClient
    private let mapper: DataToDecodableMapper<GraphQLResponse<StorePage>>

    init(
        httpClient: HttpClient,
        mapper: DataToDecodableMapper<GraphQLResponse<StorePage>>
    ) {
        self.httpClient = httpClient
        self.mapper = mapper
    }

    func get(_ query: Query) -> Future<[String: StorePage]> {
        switch query {
        case let query as StoreQuery:
            var urlRequest = httpClient.prepareURLRequest(
                path: "/graphql",
                externalId: query.userQuery.externalId,
                email: query.userQuery.email,
                hmac: query.userQuery.hmac
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
            assertionFailure("Should never happen")
            return Future(CoreError.NotImplemented())
        }
    }

    func getAll(_ query: Query) -> Future<[[String: StorePage]]> {
        assertionFailure("Should never happen")
        return Future(CoreError.NotImplemented())
    }
}
