//
//  ActionNotificationNetworkDataSource.swift
//  MagicBell
//
//  Created by Joan Martin on 19/11/21.
//

import Harmony

public class ActionNotificationNetworkDataSource: PutDataSource, DeleteDataSource {
    public typealias T = Void

    private let httpClient: HttpClient

    public init(httpClient: HttpClient) {
        self.httpClient = httpClient
    }

    public func put(_ value: Void?, in query: Query) -> Future<Void> {
        switch query {
        case let query as NotificationActionQuery:
            var path = "/notifications"
            var httpMethod = "POST"
            switch query.action {
            case .markAsRead:
                path.append("/\(query.notificationId)/read")
            case .markAsUnread:
                path.append("/\(query.notificationId)/unread")
            case .unarchive:
                path.append("/\(query.notificationId)/archive")
                httpMethod = "DELETE"
            case .archive:
                path.append("/\(query.notificationId)/archive")
            case .markAllAsRead:
                path.append("/read")
            case .markAllAsSeen:
                path.append("/seen")
            }

            var urlRequest = self.httpClient.prepareURLRequest(
                path: path,
                externalId: query.userQuery.externalId,
                email: query.userQuery.email,
                idempotentKey: query.idempotentKey
            )
            urlRequest.httpMethod = httpMethod

            return self.httpClient
                .performRequest(urlRequest)
                .map { _ in Void() }
        default:
            query.fatalError(.put, self)
        }
    }

    public func putAll(_ array: [Void], in query: Query) -> Future<[Void]> {
        query.fatalError(.putAll, self)
    }

    public func delete(_ query: Query) -> Future<Void> {
        switch query {
        case let query as NotificationQuery:
            var urlRequest = self.httpClient.prepareURLRequest(
                path: "/notifications/\(query.notificationId)",
                externalId: query.userQuery.externalId,
                email: query.userQuery.email,
                idempotentKey: query.idempotentKey
            )
            urlRequest.httpMethod = "DELETE"

            return self.httpClient
                .performRequest(urlRequest)
                .map { _ in Void() }
        default:
            query.fatalError(.put, self)
        }
    }

    public func deleteAll(_ query: Query) -> Future<Void> {
        query.fatalError(.deleteAll, self)
    }
}
