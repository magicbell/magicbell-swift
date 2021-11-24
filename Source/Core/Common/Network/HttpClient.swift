//
//  MagicBellNetworkDataSource.swift
//  MagicBell
//
//  Created by Javi on 17/11/21.
//

import Foundation
import Harmony

public protocol HttpClient {
    func prepareURLRequest(path: String, externalId: String?, email: String?) -> URLRequest
    func performRequest(_ urlRequest: URLRequest) -> Future<Data>
}

public class DefaultHttpClient: HttpClient {

    var urlSession: URLSession
    private let environment: Environment

    init(urlSession: URLSession, environment: Environment) {
        self.urlSession = urlSession
        self.environment = environment
    }

    public func prepareURLRequest(path: String, externalId: String?, email: String?) -> URLRequest {
        var urlRequest = URLRequest(url: environment.baseUrl.appendingPathComponent(path))

        urlRequest.addValue(environment.apiKey, forHTTPHeaderField: "X-MAGICBELL-API-KEY")

        if environment.isHMACEnabled {
            addHMACHeader(environment.apiSecret, externalId, email, &urlRequest)
        }
        addIdAndOrEmailHeader(externalId, email, &urlRequest)

        return urlRequest
    }

    public func performRequest(_ urlRequest: URLRequest) -> Future<Data> {
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
