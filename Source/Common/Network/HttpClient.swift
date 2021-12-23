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

protocol HttpClient {
    func prepareURLRequest(path: String, externalId: String?, email: String?) -> URLRequest
    func performRequest(_ urlRequest: URLRequest) -> Future<Data>
}

class DefaultHttpClient: HttpClient {

    var urlSession: URLSession
    private let environment: Environment

    init(urlSession: URLSession, environment: Environment) {
        self.urlSession = urlSession
        self.environment = environment
    }

    func prepareURLRequest(path: String, externalId: String?, email: String?) -> URLRequest {
        var urlRequest = URLRequest(url: environment.baseUrl.appendingPathComponent(path))

        urlRequest.addValue(environment.apiKey, forHTTPHeaderField: "X-MAGICBELL-API-KEY")

        if environment.isHMACEnabled,
           let apiSecret = environment.apiSecret {
            addHMACHeader(apiSecret, externalId, email, &urlRequest)
        }
        addIdAndOrEmailHeader(externalId, email, &urlRequest)

        urlRequest.timeoutInterval = 10

        return urlRequest
    }

    func performRequest(_ urlRequest: URLRequest) -> Future<Data> {
        Future { resolver in
            urlSession.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    resolver.set(error)
                    return
                }

                if let response = response as? HTTPURLResponse {
                    guard let data = data else {
                        resolver.set(Data())
                        return
                    }

                    if response.statusCode >= 400 {
                        // Create enum for possible errors
                        resolver.set(NetworkError(statusCode: response.statusCode, data: data))
                    } else {
                        resolver.set(data)
                    }
                }
            }.resume()
        }
    }

    private func addHMACHeader(_ apiSecret: String,
                               _ externalId: String?,
                               _ email: String?,
                               _ urlRequest: inout URLRequest) {

        if let externalId = externalId {
            let hmac: String = externalId.hmac(key: apiSecret)
            urlRequest.addValue(hmac, forHTTPHeaderField: "X-MAGICBELL-USER-HMAC")
        } else if let email = email {
            let hmac: String = email.hmac(key: apiSecret)
            urlRequest.addValue(hmac, forHTTPHeaderField: "X-MAGICBELL-USER-HMAC")
        }
    }

    private func addIdAndOrEmailHeader(_ externalId: String?,
                                       _ email: String?,
                                       _ urlRequest: inout URLRequest) {

        if let externalId = externalId {
            urlRequest.addValue(externalId, forHTTPHeaderField: "X-MAGICBELL-USER-EXTERNAL-ID")
        }
        if let email = email {
            urlRequest.addValue(email, forHTTPHeaderField: "X-MAGICBELL-USER-EMAIL")
        }
    }
}
