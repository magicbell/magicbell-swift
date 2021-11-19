//
//  APNNetworkDataSource.swift
//  MagicBell
//
//  Created by Javi on 18/11/21.
//

import Foundation
import Harmony

class PushSubscriptionNetworkDataSource: MagicBellNetworkDataSource<PushSubscription> {
    typealias T = PushSubscription

    private let environment: Environment

    public init(environment: Environment,
                urlSession: URLSession,
                mapper: DataToDecodableMapper<PushSubscription>) {
        self.environment = environment
        super.init(urlSession: urlSession, mapper: mapper)
    }
}

extension PushSubscriptionNetworkDataSource: PutDataSource {
    func put(_ value: PushSubscription?, in query: Query) -> Future<PushSubscription> {
        switch query {
        case let pushSubscriptionQuery as RegisterPushSubscriptionQuery:
            guard let value = value else {
                return Future(NetworkError(message: "Value cannot be nil"))
            }
            var urlRequest = prepareURLRequest(
                    baseURL: environment.baseUrl,
                    path: "/push_subscriptions",
                    apiKey: environment.apiKey,
                    apiSecret: environment.apiSecret,
                    externalId: pushSubscriptionQuery.user.externalId,
                    email: pushSubscriptionQuery.user.email,
                    isHMACEnabled: environment.isHMACEnabled)
            urlRequest.httpMethod = "POST"
            do {
                urlRequest.httpBody = try JSONEncoder().encode(value)
            } catch {
                return Future(MappingError<T>(error))
            }
            return performRequest(urlRequest)
        default:
            query.fatalError(.put, self)
        }
    }

    func putAll(_ array: [PushSubscription], in query: Query) -> Future<[PushSubscription]> {
        query.fatalError(.putAll, self)
    }
}

extension PushSubscriptionNetworkDataSource: DeleteDataSource {
    public func delete(_ query: Query) -> Future<Void> {
        switch query {
        case let deletePushSubscriptionQuery as DeletePushSubscriptionQuery:
            var urlRequest = prepareURLRequest(
                    baseURL: environment.baseUrl,
                    path: "/push_subscriptions/\(deletePushSubscriptionQuery.deviceToken)",
                    apiKey: environment.apiKey,
                    apiSecret: environment.apiSecret,
                    externalId: deletePushSubscriptionQuery.user.externalId,
                    email: deletePushSubscriptionQuery.user.email,
                    isHMACEnabled: environment.isHMACEnabled)

            urlRequest.httpMethod = "DELETE"

            return performDeleteRequest(urlRequest)
        default:
            query.fatalError(.delete, self)
        }
    }

    func deleteAll(_ query: Query) -> Future<Void> {
        query.fatalError(.deleteAll, self)
    }
}
