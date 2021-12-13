//
//  Stores.swift
//  MagicBell
//
//  Created by Javi on 25/11/21.
//

import Foundation

public struct Stores: Codable {
    enum DataContainerKeys: String, CodingKey {
        case data
    }

    let stores: [String: StorePage]

    public init(from decoder: Decoder) throws {
        let dataContainer = try decoder.container(keyedBy: DataContainerKeys.self)
        stores = try dataContainer.decode([String: StorePage].self, forKey: .data)
    }
}
