//
//  ErrorEntity.swift
//  MagicBell
//
//  Created by Javi on 23/11/21.
//

import Foundation

public struct ErrorEntity: Decodable {
    typealias Message = String
    var errors: [Message] = []

    func getErrorMessage(default: String) -> String {
        if !errors.isEmpty {
            let errorString = Array(errors).joined(separator: " -- ")
            return errorString
        } else {
            return `default`
        }
    }

    enum ContainerKeys: String, CodingKey {
        case errors
    }

    enum CodingKeys: String, CodingKey {
        case message
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ContainerKeys.self)
        var values = try container.nestedUnkeyedContainer(forKey: .errors)
        while !values.isAtEnd {
            let messagesContainer = try values.nestedContainer(keyedBy: CodingKeys.self)
            let message = try messagesContainer.decode(Message.self, forKey: .message)
            errors.append(message)
        }
    }
}
