//
//  APNNetworkDataSource.swift
//  MagicBell
//
//  Created by Javi on 18/11/21.
//

import Foundation
import Harmony

class PushSubscriptionNetworkDataSource: PutDataSource, DeleteDataSource {
    typealias T = PushSubscription

    private let httpClient: HttpClient
    private let mapper: Mapper<Data, PushSubscription>

    public init(httpClient: HttpClient,
                mapper: Mapper<Data, PushSubscription>) {
        self.httpClient = httpClient
        self.mapper = mapper
    }

    func put(_ value: PushSubscription?, in query: Query) -> Future<PushSubscription> {
        switch query {
        case let query as UserQuery:
            guard let value = value else {
                return Future(NetworkError(message: "Value cannot be nil"))
            }
            var urlRequest = httpClient.prepareURLRequest(
                path: "/push_subscriptions",
                externalId: query.externalId,
                email: query.email,
                idempotentKey: query.idempotentKey
            )
            urlRequest.httpMethod = "POST"
            do {
                urlRequest.httpBody = try JSONEncoder().encode(value)
            } catch {
                return Future(MappingError(className: "\(T.self)"))
            }

            return self.httpClient
                .performRequest(urlRequest)
                .map { try self.mapper.map($0) }
        default:
            query.fatalError(.put, self)
        }
    }

    func putAll(_ array: [PushSubscription], in query: Query) -> Future<[PushSubscription]> {
        query.fatalError(.putAll, self)
    }

    public func delete(_ query: Query) -> Future<Void> {
        switch query {
        case let query as DeletePushSubscriptionQuery:
            var urlRequest = self.httpClient.prepareURLRequest(
                path: "/push_subscriptions/\(query.deviceToken)",
                externalId: query.userQuery.externalId,
                email: query.userQuery.email,
                idempotentKey: query.idempotentKey
            )
            urlRequest.httpMethod = "DELETE"

            return self.httpClient
                .performRequest(urlRequest)
                .map { _ in Void() }
        default:
            query.fatalError(.delete, self)
        }
    }

    func deleteAll(_ query: Query) -> Future<Void> {
        query.fatalError(.deleteAll, self)
    }
}
