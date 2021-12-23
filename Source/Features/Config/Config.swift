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

class Config: Codable {
    let channel: String

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ContainerKeys.self)
        let configContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .websocket)
        channel = try configContainer.decode(String.self, forKey: .channel)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ContainerKeys.self)
        var configContainer = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .websocket)
        try configContainer.encode(channel, forKey: .channel)
    }

    init(channel: String) {
        self.channel = channel
    }

    enum ContainerKeys: String, CodingKey {
        case websocket = "ws"
    }

    enum CodingKeys: String, CodingKey {
        case channel
    }
}
