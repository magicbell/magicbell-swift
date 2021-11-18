//
//  NetworkError.swift
//  MagicBell
//
//  Created by Javi on 18/11/21.
//

import Foundation

public class NetworkError: LocalizedError {
    private static let defaultErrorMessage = "Network error. Custom message not provided."

    public var errorDescription: String {
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
            let errors = try JSONDecoder().decode(Errors.self, from: data)
            self.init(statusCode: statusCode, message: errors.getErrorMessage())
        } catch {
            self.init(statusCode: statusCode, message: NetworkError.defaultErrorMessage)
        }
    }

    convenience init(message: String) {
        self.init(statusCode: -1, message: message)
    }

    struct Errors: Codable {
        let errors: [Message]

        func getErrorMessage() -> String {
            if !errors.isEmpty {
                return errors.map { message in
                    message.message
                }.joined(separator: "\n")
            } else {
                return defaultErrorMessage
            }
        }
    }

    struct Message: Codable {
        let message: String
    }
}
