//
//  UserPreferencesNetworkDataSource.swift
//  MagicBell
//
//  Created by Javi on 17/11/21.
//

import Foundation
import Harmony

public class UserPreferencesNetworkDataSource {

    public typealias T = UserPreferences

    private let environment: Environment
    private let httpClient: HttpClient
    private let mapper: DataToDecodableMapper<T>

    public init(environment: Environment,
                httpClient: HttpClient,
                mapper: DataToDecodableMapper<T>) {
        self.environment = environment
        self.httpClient = httpClient
        self.mapper = mapper
    }
}

extension UserPreferencesNetworkDataSource: GetDataSource {
    public func get(_ query: Query) -> Future<UserPreferences> {
        switch query {
        case let userQuery as UserQuery:
            let urlRequest = self.httpClient.prepareURLRequest(
                baseURL: environment.baseUrl,
                path: "/notification_preferences",
                apiKey: environment.apiKey,
                apiSecret: environment.apiSecret,
                externalId: userQuery.externalId,
                email: userQuery.email,
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

    public func getAll(_ query: Query) -> Future<[UserPreferences]> {
        query.fatalError(.getAll, self)
    }
}


extension UserPreferencesNetworkDataSource: PutDataSource {
    public func put(_ value: UserPreferences?, in query: Query) -> Future<UserPreferences> {
        switch query {
        case let userQuery as UserQuery:
            guard let value = value else {
                return Future(CoreError.NotValid())
            }

            var urlRequest = self.httpClient.prepareURLRequest(
                baseURL: environment.baseUrl,
                path: "/notification_preferences",
                apiKey: environment.apiKey,
                apiSecret: environment.apiSecret,
                externalId: userQuery.externalId,
                email: userQuery.email,
                isHMACEnabled: environment.isHMACEnabled)

            urlRequest.httpMethod = "PUT"

            do {
                urlRequest.httpBody = try JSONEncoder().encode(value)
            } catch {
                return Future(MappingError<T>(error))
            }
            return self.httpClient.performRequest(urlRequest).map { data in
                try self.mapper.map(data)
            }.recover { error in
                Future(error)
            }
        default:
            query.fatalError(.get, self)
        }
    }

    public func putAll(_ array: [UserPreferences], in query: Query) -> Future<[UserPreferences]> {
        query.fatalError(.putAll, self)
    }
}
