//
//  NotificationNetworkDataSource.swift
//  MagicBell
//
//  Created by Javi on 18/11/21.
//

import Foundation
import Harmony

public class NotificationNetworkDataSource {
    private let environment: Environment
    private let httpClient: HttpClient
    private let mapper: DataToDecodableMapper<Notification>

    public init(environment: Environment,
                httpClient: HttpClient,
                mapper: DataToDecodableMapper<Notification>) {
        self.environment = environment
        self.httpClient = httpClient
        self.mapper = mapper
    }
}

extension NotificationNetworkDataSource: GetDataSource {
    public typealias T = Notification

    public func get(_ query: Query) -> Future<Notification> {
        switch query {
        case let notificationQuery as NotificationQuery:
            let urlRequest = self.httpClient.prepareURLRequest(
                    baseURL: environment.baseUrl,
                    path: "/notifications/\(notificationQuery.notificationId)",
                    apiKey: environment.apiKey,
                    apiSecret: environment.apiSecret,
                    externalId: notificationQuery.user.externalId,
                    email: notificationQuery.user.email,
                    isHMACEnabled: environment.isHMACEnabled)

            return self.httpClient.performRequest(urlRequest).map { data in
                try self.mapper.map(data)
            }.recover { error in
                Future(error)
            }
        default:
            query.fatalError(.get, self)
        }
    }

    public func getAll(_ query: Query) -> Future<[Notification]> {
        query.fatalError(.getAll, self)
    }
}

public class ActionNotificationNetworkDataSource {
    public typealias T = Void

    private let environment: Environment
    private let httpClient: HttpClient
    private let mapper: Mapper<Data, Void>

    public init(environment: Environment,
                httpClient: HttpClient) {
        self.environment = environment
        self.httpClient = httpClient
        self.mapper = ClosureMapper { _ in
            Void()
        }
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

            var urlRequest = self.httpClient.prepareURLRequest(
                    baseURL: environment.baseUrl,
                    path: path,
                    apiKey: environment.apiKey,
                    apiSecret: environment.apiSecret,
                    externalId: notificationActionQuery.user.externalId,
                    email: notificationActionQuery.user.email,
                    isHMACEnabled: environment.isHMACEnabled)

            urlRequest.httpMethod = httpMethod

            return self.httpClient.performRequest(urlRequest).map { data in
                try self.mapper.map(data)
            }.recover { error in
                Future(error)
            }
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
            var urlRequest = self.httpClient.prepareURLRequest(
                    baseURL: environment.baseUrl,
                    path: "/notifications/\(notificationQuery.notificationId)",
                    apiKey: environment.apiKey,
                    apiSecret: environment.apiSecret,
                    externalId: notificationQuery.user.externalId,
                    email: notificationQuery.user.email,
                    isHMACEnabled: environment.isHMACEnabled)

            urlRequest.httpMethod = "DELETE"

            return self.httpClient.performRequest(urlRequest).map { data in
                try self.mapper.map(data)
            }.recover { error in
                Future(error)
            }
        default:
            query.fatalError(.put, self)
        }
    }

    public func deleteAll(_ query: Query) -> Future<Void> {
        query.fatalError(.deleteAll, self)
    }
}
