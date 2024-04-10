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
    func prepareURLRequest(path: String, externalId: String?, email: String?, hmac: String?, additionalHTTPHeaders: [String: String]?) -> URLRequest
    func performRequest(_ urlRequest: URLRequest) -> Future<Data>
}
extension HttpClient {
    func prepareURLRequest(path: String, externalId: String?, email: String?, hmac: String?) -> URLRequest {
        prepareURLRequest(path: path, externalId: externalId, email: email, hmac: hmac, additionalHTTPHeaders: [:])
    }
}

class DefaultHttpClient: HttpClient {

    var urlSession: URLSession
    private let environment: Environment

    init(urlSession: URLSession, environment: Environment) {
        self.urlSession = urlSession
        self.environment = environment
    }
    
    func prepareURLRequest(path: String, externalId: String?, email: String?, hmac: String?, additionalHTTPHeaders: [String: String]?) -> URLRequest {
        var urlRequest = URLRequest(url: environment.baseUrl.appendingPathComponent(path))

        urlRequest.addValue(environment.apiKey, forHTTPHeaderField: "X-MAGICBELL-API-KEY")

        if environment.isHMACEnabled,
           let hmac = hmac {
            urlRequest.addValue(hmac, forHTTPHeaderField: "X-MAGICBELL-USER-HMAC")
        }
        addIdAndOrEmailHeader(externalId, email, &urlRequest)
        
        if let headers = additionalHTTPHeaders {
            headers.forEach { (key: String, value: String) in
                urlRequest.addValue(value, forHTTPHeaderField: key)
            }
        }

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
