//
//  MagicBellNetworkDataSource.swift
//  MagicBell
//
//  Created by Javi on 17/11/21.
//

import Foundation
import Harmony

public class HttpClient {

    private let urlSession: URLSession

    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }

    func prepareURLRequest(baseURL: URL,
                           path: String,
                           apiKey: String,
                           apiSecret: String,
                           externalId: String?,
                           email: String?,
                           isHMACEnabled: Bool) -> URLRequest {
        var urlRequest = URLRequest(url: baseURL.appendingPathComponent(path))

        urlRequest.addValue(apiKey, forHTTPHeaderField: "X-MAGICBELL-API-KEY")

        if isHMACEnabled {
            addHMACHeader(apiSecret, externalId, email, &urlRequest)
        }
        addIdAndOrEmailHeader(externalId, email, &urlRequest)

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
