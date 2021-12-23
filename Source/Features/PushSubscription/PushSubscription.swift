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

struct PushSubscription: Codable {
    static let platformIOS = "ios"
    
    public let id: String?
    public let deviceToken: String
    public let platform: String

    init(id: String? = nil, deviceToken: String, platform: String) {
        self.id = id
        self.deviceToken = deviceToken
        self.platform = platform
    }

    enum ContainerKeys: String, CodingKey {
        case pushSubscription = "push_subscription"
    }

    enum CodingKeys: String, CodingKey {
        case id
        case deviceToken = "device_token"
        case platform
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ContainerKeys.self)
        let values = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .pushSubscription)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        deviceToken = try values.decode(String.self, forKey: .deviceToken)
        platform = try values.decode(String.self, forKey: .platform)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ContainerKeys.self)
        var pushSubscriptionContainer = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .pushSubscription)
        try pushSubscriptionContainer.encode(deviceToken, forKey: .deviceToken)
        try pushSubscriptionContainer.encode(platform, forKey: .platform)
    }
}
