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

struct APNSToken: Codable {
    public let deviceToken: String
    public let installationId: APNSEnvironment

    init(deviceToken: String, installationId: APNSEnvironment) {
        self.deviceToken = deviceToken
        self.installationId = installationId
    }

    enum ContainerKeys: String, CodingKey {
        case apns = "apns"
    }

    enum CodingKeys: String, CodingKey {
        case deviceToken = "device_token"
        case installationId = "installation_id"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ContainerKeys.self)
        let values = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .apns)
        deviceToken = try values.decode(String.self, forKey: .deviceToken)
        installationId = APNSEnvironment(rawValue: try values.decode(String.self, forKey: .installationId)) ?? .development
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ContainerKeys.self)
        var apnsContainer = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .apns)
        try apnsContainer.encode(deviceToken, forKey: .deviceToken)
        try apnsContainer.encode(installationId, forKey: .installationId)
    }
}
