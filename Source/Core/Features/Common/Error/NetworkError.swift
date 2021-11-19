//
//  NetworkError.swift
//  MagicBell
//
//  Created by Javi on 18/11/21.
//

import Foundation

public class NetworkError: LocalizedError {
    private static let defaultErrorMessage = "Network error. Custom message not provided."

    public var errorDescription: String? {
        "\(statusCode) - \(message ?? NetworkError.defaultErrorMessage)"
    }

    public let statusCode: Int
    public let message: String?

    init(statusCode: Int, message: String?) {
        self.statusCode = statusCode
        self.message = message
    }

    convenience init(statusCode: Int, data: Data) {
        do {
            #if DEBUG
            print(String(data: data, encoding: .utf8) ?? "Cannot decode error message")
            #endif
            let errors = try JSONDecoder().decode(Errors.self, from: data)
            self.init(statusCode: statusCode, message: errors.getErrorMessage())
        } catch {
            self.init(statusCode: statusCode, message: NetworkError.defaultErrorMessage)
        }
    }

    convenience init(message: String) {
        self.init(statusCode: -1, message: message)
    }

    private struct Errors: Decodable {
        typealias Message = String
        var errors: [Message] = []

        func getErrorMessage() -> String {
            if !errors.isEmpty {
                let errorString = errors.map { message in
                    message
                }.joined(separator: " -- ")
                return errorString
            } else {
                return defaultErrorMessage
            }
        }

        enum ContainerKeys: String, CodingKey {
            case errors
        }

        enum CodingKeys: String, CodingKey {
            case message
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: ContainerKeys.self)
            var values = try container.nestedUnkeyedContainer(forKey: .errors)
            while !values.isAtEnd {
                let messagesContainer = try values.nestedContainer(keyedBy: CodingKeys.self)
                let message = try messagesContainer.decode(Message.self, forKey: .message)
                errors.append(message)
            }
        }
    }
}
