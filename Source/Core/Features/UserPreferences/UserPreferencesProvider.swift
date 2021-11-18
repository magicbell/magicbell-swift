//
//  UserPreferencesProvider.swift
//  MagicBell
//
//  Created by Javi on 17/11/21.
//

import Foundation
import Harmony

protocol UserPreferencesComponent {
    func getUserPreferencesNetworkDataSource() -> AnyGetDataSource<UserPreferences>
    func getPutUserPreferenceNetworkDataSource() -> AnyPutDataSource<UserPreferences>
}

class DefaultUserPreferencesModule: UserPreferencesComponent {

    private let environment: Environment
    private let urlSession: URLSession

    init(environment: Environment,
         urlSession: URLSession) {
        self.environment = environment
        self.urlSession = urlSession
    }

    private lazy var userPreferencesNetworkDatasource = UserPreferencesNetworkDataSource(
            environment: environment,
            urlSession: urlSession,
            mapper: DataToDecodableMapper<UserPreferences>())


    func getUserPreferencesNetworkDataSource() -> AnyGetDataSource<UserPreferences> {
        AnyGetDataSource(userPreferencesNetworkDatasource)
    }

    func getPutUserPreferenceNetworkDataSource() -> AnyPutDataSource<UserPreferences> {
        AnyPutDataSource(userPreferencesNetworkDatasource)
    }
}
