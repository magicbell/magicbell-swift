//
//  Config.swift
//  MagicBell
//
//  Created by Javi on 16/11/21.
//

import Foundation

public class Config: Decodable {
    public let channel: String

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let configContainer = try container
                .nestedContainer(keyedBy: WebserviceKeys.self, forKey: .ws)
        channel = try configContainer.decode(String.self, forKey: .channel)
    }

    enum CodingKeys: String, CodingKey {
        case ws
    }

    enum WebserviceKeys: String, CodingKey {
        case channel
    }
}
