//
//  GraphQLResult.swift
//  MagicBell
//
//  Created by Joan Martin on 26/11/21.
//

import Foundation

struct GraphQLResponse<T: Codable>: Codable {
    enum DataContainerKeys: String, CodingKey {
        case data
    }

    let response: [String: T]

    init(from decoder: Decoder) throws {
        let dataContainer = try decoder.container(keyedBy: DataContainerKeys.self)
        response = try dataContainer.decode([String: T].self, forKey: .data)
    }
}
