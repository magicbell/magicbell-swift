//
//  NetworkError.swift
//  MagicBell
//
//  Created by Javi on 18/11/21.
//

import Foundation

class NetworkError: LocalizedError {
    private static let defaultErrorMessage = "Network error. Custom message not provided."

    var errorDescription: String? {
        "\(statusCode) - \(message ?? NetworkError.defaultErrorMessage)"
    }

    let statusCode: Int
    let message: String?

    init(statusCode: Int, message: String?) {
        self.statusCode = statusCode
        self.message = message
    }

    convenience init(statusCode: Int, data: Data) {
        do {
            #if DEBUG
            print(String(data: data, encoding: .utf8) ?? "Cannot decode error message")
            #endif
            let errors = try JSONDecoder().decode(ErrorEntity.self, from: data)
            self.init(statusCode: statusCode, message: errors.getErrorMessage(default: NetworkError.defaultErrorMessage))
        } catch {
            self.init(statusCode: statusCode, message: NetworkError.defaultErrorMessage)
        }
    }

    convenience init(message: String) {
        self.init(statusCode: -1, message: message)
    }
}
