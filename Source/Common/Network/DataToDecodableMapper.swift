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
import Harmony

class DataToDecodableMapper<T>: Mapper<Data, T> where T: Decodable {

    private var decoder = JSONDecoder()

    override func map(_ from: Data) throws -> T {
        do {
            let value = try decoder.decode(T.self, from: from)
            return value
        } catch {
            #if DEBUG
            switch error {
            case let decodingError as DecodingError:
                switch decodingError {
                case let .dataCorrupted(context):
                    print(context)
                case let .keyNotFound(key, context):
                    print("Key '\(key)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                case let .valueNotFound(value, context):
                    print("Value '\(value)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                case let .typeMismatch(type, context):
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                @unknown default:
                    print(error)
                }
            default:
                print("error: ", error)
            }
            #endif

            throw MappingError(className: "\(T.self)")
        }
    }
}
