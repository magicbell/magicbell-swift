//
// By downloading or using this software made available by MagicBell, Inc.
// ("MagicBell") or any documentation that accompanies it (collectively, the
// "Software"), you and the company or entity that you represent (collectively,
// "you" or "your") are consenting to be bound by and are becoming a party to this
// License Agreement (this "Agreement"). You hereby represent and warrant that you
// are authorized and lawfully able to bind such company or entity that you
// represent to this Agreement.  If you do not have such authority or do not agree
// to all of the terms of this Agreement, you may not download or use the Software.
//
// For more information, read the LICENSE file.
//

import Harmony

class UserPreferencesEntityToUserPreferencesMapper: Mapper<UserPreferencesEntity, UserPreferences> {
    override func map(_ from: UserPreferencesEntity) throws -> UserPreferences {
        
        if let preferencesEntity = from.preferences {
            let categories = Dictionary(uniqueKeysWithValues: preferencesEntity.map { key, value in
                (key,
                 Preferences(email: value.email,
                             inApp: value.inApp,
                             mobilePush: value.mobilePush,
                             webPush: value.webPush))
            })
            return UserPreferences(categories)
        } else {
            return UserPreferences([:])
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
