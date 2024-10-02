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

class StoreDataSource: GetDataSource {

    typealias T = StorePage

    private let httpClient: HttpClient
    private let mapper: Mapper<Data, StorePage>

    init(httpClient: HttpClient, mapper: Mapper<Data, StorePage>) {
        self.httpClient = httpClient
        self.mapper = mapper
    }

    func get(_ query: Query) -> Future<StorePage> {
        switch query {
        case let storeQuery as StoreQuery:
            let userQuery = storeQuery.userQuery
            let urlRequest = httpClient.prepareURLRequest(
                path: "/notifications",
                externalId: userQuery.externalId,
                email: userQuery.email,
                hmac: userQuery.hmac,
                queryItems: storeQuery.context.asQueryItems
            )
            return httpClient
                .performRequest(urlRequest)
                .map { try self.mapper.map($0) }
        default:
            assertionFailure("Should never happen")
            return Future(CoreError.NotImplemented())
        }
    }

    func getAll(_ query: Query) -> Future<[StorePage]> {
        assertionFailure("Should never happen")
        return Future(CoreError.NotImplemented())
    }
}