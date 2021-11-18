//
//  NotificationNetworkDataSource.swift
//  MagicBell
//
//  Created by Javi on 18/11/21.
//

import Foundation
import Harmony

public class NotificationNetworkDataSource: MagicBellNetworkDataSource<Notification> {
    private let environment: Environment

    public init(environment: Environment,
                urlSession: URLSession,
                mapper: DataToDecodableMapper<Notification>) {
        self.environment = environment
        super.init(urlSession: urlSession, mapper: mapper)
    }
}

extension NotificationNetworkDataSource: GetDataSource {
    public typealias T = Notification

    public func get(_ query: Query) -> Future<Notification> {
        switch query {
        case let notificationQuery as NotificationQuery:
            let urlRequest = prepareURLRequest(
                    baseURL: environment.baseUrl,
                    path: "/notifications/\(notificationQuery.notificationId)",
                    apiKey: environment.apiKey,
                    apiSecret: environment.apiSecret,
                    externalId: notificationQuery.user.externalId,
                    email: notificationQuery.user.email,
                    isHMACEnabled: environment.isHMACEnabled)

            return performRequest(urlRequest)
        default:
            query.fatalError(.get, self)
        }
    }

    public func getAll(_ query: Query) -> Future<[Notification]> {
        query.fatalError(.getAll, self)
    }
}

public class ActionNotificationNetworkDataSource: MagicBellNetworkDataSource<Void> {
    public typealias T = Void

    private let environment: Environment

    public init(environment: Environment,
                urlSession: URLSession) {
        self.environment = environment
        super.init(urlSession: urlSession, mapper: ClosureMapper { _ in
            Void()
        })
    }
}

extension ActionNotificationNetworkDataSource: PutDataSource {
    public func put(_ value: Void?, in query: Query) -> Future<Void> {
        switch query {
        case let notificationActionQuery as NotificationActionQuery:
            var path = "/notifications"
            var httpMethod = "POST"
            switch notificationActionQuery.action {
            case .markAsRead:
                path.append("/\(notificationActionQuery.notificationId)/read")
            case .markAsUnread:
                path.append("/\(notificationActionQuery.notificationId)/unread")
            case .unarchive:
                path.append("/\(notificationActionQuery.notificationId)/archive")
                httpMethod = "DELETE"
            case .archive:
                path.append("/\(notificationActionQuery.notificationId)/archive")
            case .markAllAsRead:
                path.append("/read")
            case .markAllAsSeen:
                path.append("/seen")
            }

            var urlRequest = prepareURLRequest(
                    baseURL: environment.baseUrl,
                    path: path,
                    apiKey: environment.apiKey,
                    apiSecret: environment.apiSecret,
                    externalId: notificationActionQuery.user.externalId,
                    email: notificationActionQuery.user.email,
                    isHMACEnabled: environment.isHMACEnabled)

            urlRequest.httpMethod = httpMethod

            return performRequest(urlRequest)
        default:
            query.fatalError(.put, self)
        }
    }

    public func putAll(_ array: [Void], in query: Query) -> Future<[Void]> {
        query.fatalError(.putAll, self)
    }
}

extension ActionNotificationNetworkDataSource: DeleteDataSource {
    public func delete(_ query: Query) -> Future<Void> {
        switch query {
        case let notificationQuery as NotificationQuery:
            var urlRequest = prepareURLRequest(
                    baseURL: environment.baseUrl,
                    path: "/notifications/\(notificationQuery.notificationId)",
                    apiKey: environment.apiKey,
                    apiSecret: environment.apiSecret,
                    externalId: notificationQuery.user.externalId,
                    email: notificationQuery.user.email,
                    isHMACEnabled: environment.isHMACEnabled)

            urlRequest.httpMethod = "DELETE"

            return performRequest(urlRequest)
        default:
            query.fatalError(.put, self)
        }
    }

    public func deleteAll(_ query: Query) -> Future<Void> {
        query.fatalError(.deleteAll, self)
    }
}
