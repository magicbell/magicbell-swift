//
//  UserPreferencesMapper.swift
//  MagicBell
//
//  Created by Javi on 9/12/21.
//

import Harmony

class UserPreferencesEntityToUserPreferencesMapper: Mapper<UserPreferencesEntity, UserPreferences> {
    override func map(_ from: UserPreferencesEntity) throws -> UserPreferences {

        if let preferencesEntity = from.preferences {
            let categories = Dictionary(uniqueKeysWithValues:
                                        preferencesEntity.map { key, value in (key, Preferences(email: value.email, inApp: value.inApp, mobilePush: value.mobilePush, webPush: value.webPush)) })
            return UserPreferences(categories: categories)
        } else {
            return UserPreferences(categories: [:])
        }
    }
}

class UserPreferencesToUserPreferencesEntityMapper: Mapper<UserPreferences, UserPreferencesEntity> {
    override func map(_ from: UserPreferences) throws -> UserPreferencesEntity {
        let userPreferencesEntity = Dictionary(uniqueKeysWithValues: from.preferences.map { key, value in
            (key,
             PreferencesEntity(email: value.email,
                               inApp: value.inApp,
                               mobilePush: value.mobilePush,
                               webPush: value.webPush))
        })
        return UserPreferencesEntity(preferences: userPreferencesEntity)
    }
}
