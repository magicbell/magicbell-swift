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
        let categories = from.categories.map { category in
            let channels = category.channels.map { channel in
                Channel(label: channel.label, slug: channel.slug, enabled: channel.enabled)
            }
            return Category(channels: channels, label: category.label, slug: category.slug)
        }
        return UserPreferences(categories: categories)
    }
}

class UserPreferencesToUserPreferencesEntityMapper: Mapper<UserPreferences, UserPreferencesEntity> {
    override func map(_ from: UserPreferences) throws -> UserPreferencesEntity {
        
        let categories = from.categories.map { value in
            let channels = value.channels.map { channel in
                ChannelEntity(label: channel.label,
                              slug: channel.slug,
                              enabled: channel.enabled)}
            return CategoryEntity(label: value.label,
                                  slug: value.slug,
                                  channels: channels)
        }
        return UserPreferencesEntity(categories: categories)
    }
}
