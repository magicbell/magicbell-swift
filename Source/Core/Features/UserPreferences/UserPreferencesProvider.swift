//
//  UserPreferencesProvider.swift
//  MagicBell
//
//  Created by Javi on 17/11/21.
//

import Foundation
import Harmony

public protocol UserPreferencesComponent {
    func getUserPreferencesNetworkDataSource() -> AnyGetDataSource<UserPreferences>
    func getPutUserPreferenceNetworkDataSource() -> AnyPutDataSource<UserPreferences>
}

public class DefaultUserPreferencesModule: UserPreferencesComponent {
    private let httpClient: HttpClient

    init(httpClient: HttpClient) {
        self.httpClient = httpClient
    }

    private lazy var userPreferencesNetworkDatasource = UserPreferencesNetworkDataSource(
        httpClient: httpClient,
        mapper: DataToDecodableMapper<UserPreferences>()
    )

    public func getUserPreferencesNetworkDataSource() -> AnyGetDataSource<UserPreferences> {
        AnyGetDataSource(userPreferencesNetworkDatasource)
    }

    public func getPutUserPreferenceNetworkDataSource() -> AnyPutDataSource<UserPreferences> {
        AnyPutDataSource(userPreferencesNetworkDatasource)
    }
}
