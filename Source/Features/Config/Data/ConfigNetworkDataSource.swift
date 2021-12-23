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
