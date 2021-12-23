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
