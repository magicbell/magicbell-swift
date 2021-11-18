//
//  APN.swift
//  MagicBell
//
//  Created by Javi on 18/11/21.
//

import Foundation

public struct PushSubscription: Codable {
    public let id: String?
    public let deviceToken, platform: String

    enum ContainerKeys: String, CodingKey {
        case pushSubscription = "push_subscription"
    }

    enum PushSubscriptionKeys: String, CodingKey {
        case id
        case deviceToken = "device_token"
        case platform
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ContainerKeys.self)
        let values = try container.nestedContainer(keyedBy: PushSubscriptionKeys.self, forKey: .pushSubscription)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        deviceToken = try values.decode(String.self, forKey: .deviceToken)
        platform = try values.decode(String.self, forKey: .platform)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ContainerKeys.self)
        var pushSubscriptionContainer = container.nestedContainer(keyedBy: PushSubscriptionKeys.self, forKey: .pushSubscription)
        try pushSubscriptionContainer.encode(deviceToken, forKey: .deviceToken)
        try pushSubscriptionContainer.encode(platform, forKey: .platform)
    }


    public init(deviceToken: String, platform: String) {
        id = nil
        self.deviceToken = deviceToken
        self.platform = platform
    }
}
