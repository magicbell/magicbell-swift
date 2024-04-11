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

import Foundation

struct ChannelEntity: Codable {
    let slug:String
    let label:String
    let enabled:Bool
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.slug, forKey: .slug)
        // try container.encode(self.label, forKey: .label) // explicitly not encoding labels, as they are not expected in PUT calls
        try container.encode(self.enabled, forKey: .enabled)
    }
}

struct CategoryEntity: Codable {
    let slug:String
    let label:String
    let channels:[ChannelEntity]
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.slug, forKey: .slug)
        // try container.encode(self.label, forKey: .label) // explicitly not encoding labels, as they are not expected in PUT calls
        try container.encode(self.channels, forKey: .channels)
    }
}

struct NotificationPreferencesEntity: Codable {
    let categories: [CategoryEntity]

    enum ContainerKeys: String, CodingKey {
        case notificationPreferences = "notification_preferences"
    }

    enum CodingKeys: String, CodingKey {
        case categories
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ContainerKeys.self)
        let values = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .notificationPreferences)
        categories = try values.decode([CategoryEntity].self, forKey: .categories)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ContainerKeys.self)
        var values = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .notificationPreferences)
        try values.encode(categories, forKey: .categories)
    }
    
    init(categories: [CategoryEntity]) {
        self.categories = categories
    }
}
