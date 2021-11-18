//
//  MagicBellNetworkDataSource.swift
//  MagicBell
//
//  Created by Javi on 17/11/21.
//

import Foundation
import Harmony

open class MagicBellNetworkDataSource<T> {

    private let urlSession: URLSession
    private let mapper: Mapper<Data, T>

    init(urlSession: URLSession,
         mapper: Mapper<Data, T>) {
        self.urlSession = urlSession
        self.mapper = mapper
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

    func performRequest(_ urlRequest: URLRequest) -> Future<T> {
        Future { resolver in
            urlSession.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    resolver.set(error)
                    return
                }

                if let response = response as? HTTPURLResponse {
                    guard let data = data else {
                        preconditionFailure("No error was received but we also don't have data...")
                    }

                    if response.statusCode >= 400 {
                        // Create enum for possible errors
                        resolver.set(NetworkError(statusCode: response.statusCode, data: data))
                    } else {
                        do {
                            let decodedObject = try self.mapper.map(data)
                            resolver.set(decodedObject)
                        } catch {
                            resolver.set(error)
                        }
                    }
                }
            }.resume()
        }
    }

    func performDeleteRequest(_ urlRequest: URLRequest) -> Future<Void> {
        Future { resolver in
            urlSession.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    resolver.set(error)
                    return
                }

                if let response = response as? HTTPURLResponse {
                    guard let data = data else {
                        preconditionFailure("No error was received but we also don't have data...")
                    }

                    if response.statusCode >= 400 {
                        // Create enum for possible errors
                        resolver.set(NetworkError(statusCode: response.statusCode, data: data))
                    } else {
                        resolver.set(Void())
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

/**
 Generic T Network -> Notification get put delete

 Notification Network

 */
