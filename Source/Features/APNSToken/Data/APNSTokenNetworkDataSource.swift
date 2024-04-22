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

class APNSTokenNetworkDataSource: PutDataSource {
    typealias T = APNSToken

    private let httpClient: HttpClient
    private let mapper: Mapper<Data, APNSToken>

    init(
        httpClient: HttpClient,
        mapper: Mapper<Data, APNSToken>
    ) {
        self.httpClient = httpClient
        self.mapper = mapper
    }

    func put(_ value: APNSToken?, in query: Query) -> Future<APNSToken> {
        guard let query = query as? RegisterAPNSTokenQuery else {
            assertionFailure("Should never happen")
            return Future(CoreError.Failed("Invalid Query"))
        }
        guard let value = value else {
            return Future(NetworkError(message: "Value cannot be nil"))
        }
        
        let user = query.user
        
        var urlRequest = httpClient.prepareURLRequest(
            path: "/channels/mobile_push/apns/tokens",
            externalId: user.externalId,
            email: user.email,
            hmac: user.hmac
        )
        urlRequest.httpMethod = "POST"
        do {
            urlRequest.httpBody = try JSONEncoder().encode(value)
        } catch {
            return Future(MappingError(className: "\(T.self)"))
        }

        return self.httpClient
            .performRequest(urlRequest)
            .map { _ in return value }
    }

    func putAll(_ array: [APNSToken], in query: Harmony.Query) -> Harmony.Future<[APNSToken]> {
        assertionFailure("Should never happen")
        return Future(CoreError.NotImplemented())
    }
}
