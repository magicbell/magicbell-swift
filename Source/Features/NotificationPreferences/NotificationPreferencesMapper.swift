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

class NotificationPreferencesEntityToNotificationPreferencesMapper: Mapper<NotificationPreferencesEntity, NotificationPreferences> {
    override func map(_ from: NotificationPreferencesEntity) throws -> NotificationPreferences {
        let categories = from.categories.map { category in
            let channels = category.channels.map { channel in
                Channel(slug: channel.slug, label: channel.label, enabled: channel.enabled)
            }
            return Category(slug: category.slug, label: category.label, channels: channels)
        }
        return NotificationPreferences(categories: categories)
    }
}

class NotificationPreferencesToNotificationPreferencesEntityMapper: Mapper<NotificationPreferences, NotificationPreferencesEntity> {
    override func map(_ from: NotificationPreferences) throws -> NotificationPreferencesEntity {
        
        let categories = from.categories.map { value in
            let channels = value.channels.map { channel in
                ChannelEntity(slug: channel.slug,
                              label: channel.label,
                              enabled: channel.enabled)}
            return CategoryEntity(slug: value.slug,
                                  label: value.label,
                                  channels: channels)
        }
        return NotificationPreferencesEntity(categories: categories)
    }
}
