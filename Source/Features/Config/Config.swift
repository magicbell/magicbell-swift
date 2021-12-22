//
//  Config.swift
//  MagicBell
//
//  Created by Javi on 16/11/21.
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
