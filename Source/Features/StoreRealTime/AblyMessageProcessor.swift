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

import Ably
import Harmony

struct AblyMessageProcessor {

    private let tag = "AblyMessageProcessor"
    private let logger: Logger

    init(logger: Logger) {
        self.logger = logger
    }

    enum Message {
        case new(notificationId: String)
        case read(notificationId: String)
        case unread(notificationId: String)
        case delete(notificationId: String)
        case archived(notificationId: String)
        case readAll
        case seenAll
    }

    func processAblyMessage(_ message: ARTMessage) throws -> Message {
        print(message)
        if let event = message.name,
           let eventData = message.data as? [String: String?] {
            let eventParts = event.split(separator: "/", maxSplits: 1)
            if !eventParts.isEmpty &&
                eventParts.count == 2 &&
                eventParts[0] == "notifications" {
                return try obtainMessage(eventName: String(eventParts[1]), notificationId: eventData["id"] as? String)
            } else {
                throw MagicBellError("Ably message has bad format")
            }
        } else {
            throw MagicBellError("Ably message has bad format")
        }
    }

    private func obtainMessage(eventName: String, notificationId: String?) throws -> Message {
        if let notificationId = notificationId {
            switch eventName {
            case "new":
                return .new(notificationId: notificationId)
            case "read":
                return .read(notificationId: notificationId)
            case "unread":
                return .unread(notificationId: notificationId)
            case "delete":
                return .delete(notificationId: notificationId)
            case "archived":
                return .archived(notificationId: notificationId)
            default:
                throw MagicBellError("Ably event cannot be handled")
            }
        } else {
            switch eventName {
            case "read/all":
                return .readAll
            case "seen/all":
                return .seenAll
            default:
                throw MagicBellError("Ably event cannot be handled")
            }
        }
    }
}
