//
//  PushSubscription.swift
//  MagicBell
//
//  Created by Javi on 18/11/21.
//

import Foundation

public struct PushSubscription: Codable {
    static let platformIOS = "ios"
    
    public let id: String?
    public let deviceToken: String
    public let platform: String

    public init(id: String? = nil, deviceToken: String, platform: String) {
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

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ContainerKeys.self)
        let values = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .pushSubscription)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        deviceToken = try values.decode(String.self, forKey: .deviceToken)
        platform = try values.decode(String.self, forKey: .platform)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ContainerKeys.self)
        var pushSubscriptionContainer = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .pushSubscription)
        try pushSubscriptionContainer.encode(deviceToken, forKey: .deviceToken)
        try pushSubscriptionContainer.encode(platform, forKey: .platform)
    }
}
