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
    func prepareURLRequest(path: String, externalId: String?, email: String?, idempotentKey: String?) -> URLRequest
    func performRequest(_ urlRequest: URLRequest) -> Future<Data>
}

extension HttpClient {
    // Extending to make idempotentKey optional and default to nil
    public func prepareURLRequest(path: String, externalId: String?, email: String?) -> URLRequest {
        return prepareURLRequest(path: path, externalId: externalId, email: email, idempotentKey: nil)
    }
}

public class DefaultHttpClient: HttpClient {

    var urlSession: URLSession
    private let environment: Environment

    init(urlSession: URLSession, environment: Environment) {
        self.urlSession = urlSession
        self.environment = environment
    }

    public func prepareURLRequest(path: String, externalId: String?, email: String?, idempotentKey: String? = nil) -> URLRequest {
        var urlRequest = URLRequest(url: environment.baseUrl.appendingPathComponent(path))

        // Adding API Key
        addAPIKeyHeader(environment.apiKey, urlRequest: &urlRequest)

        // Adding User Authentication headers
        addUserAuthenticationHeaders(
            externalId: externalId,
            email: email,
            urlRequest: &urlRequest
        )

        // Adding HMAC if enabled
        if environment.isHMACEnabled {
            addHMACHeader(
                apiSecret: environment.apiSecret,
                externalId: externalId,
                email: email,
                urlRequest: &urlRequest
            )
        }

        // Adding idempotent key if defined
        if let key = idempotentKey {
            addIdempotentKeyHeader(key, urlRequest: &urlRequest)
        }

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


    private func addAPIKeyHeader(_ apiKey: String, urlRequest: inout URLRequest) {
        urlRequest.addValue(apiKey, forHTTPHeaderField: "X-MAGICBELL-API-KEY")
    }

    private func addIdempotentKeyHeader(_ idempotentKey: String, urlRequest: inout URLRequest) {
        urlRequest.addValue(idempotentKey, forHTTPHeaderField: "IDEMPOTENCY-KEY")
    }

    private func addHMACHeader(
        apiSecret: String,
        externalId: String?,
        email: String?,
        urlRequest: inout URLRequest
    ) {
        if let externalId = externalId {
            let hmac: String = externalId.hmac(key: apiSecret)
            urlRequest.addValue(hmac, forHTTPHeaderField: "X-MAGICBELL-USER-HMAC")
        } else if let email = email {
            let hmac: String = email.hmac(key: apiSecret)
            urlRequest.addValue(hmac, forHTTPHeaderField: "X-MAGICBELL-USER-HMAC")
        }
    }

    private func addUserAuthenticationHeaders(
        externalId: String?,
        email: String?,
        urlRequest: inout URLRequest
    ) {
        if let externalId = externalId {
            urlRequest.addValue(externalId, forHTTPHeaderField: "X-MAGICBELL-USER-EXTERNAL-ID")
        }
        if let email = email {
            urlRequest.addValue(email, forHTTPHeaderField: "X-MAGICBELL-USER-EMAIL")
        }
    }
}
