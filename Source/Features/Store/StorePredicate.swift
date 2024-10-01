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

/// The notificaiton store predicate
public struct StorePredicate {
    public let read: Bool?
    public let seen: Bool?
    public let archived: Bool
    public let category: String?
    public let topic: String?

    /// Predicate default initializer
    /// - Parameters:
    ///   - read: The read status. Defaults to `nil` (not specified).
    ///   - seen: The seen status. Defaults to `nil` (not specified).
    ///   - archived: The archived status. Defaults to `false` (unarchived).
    ///   - category: The category. Defaults to nil.
    ///   - topic: The topic. Defaults to nil.
    public init(read: Bool? = nil,
                seen: Bool? = nil,
                archived: Bool = false,
                category: String? = nil,
                topic: String? = nil) {
        self.read = read
        self.seen = seen
        self.archived = archived
        self.category = category
        self.topic = topic
    }
}

extension StorePredicate: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(read.hashValue)
        hasher.combine(seen.hashValue)
        hasher.combine(archived.hashValue)
        hasher.combine(category.hashValue)
        hasher.combine(topic.hashValue)
    }
}

extension StorePredicate: Equatable {
    public static func == (lhs: StorePredicate, rhs: StorePredicate) -> Bool {
        if lhs.read != rhs.read {
            return false
        }
        if lhs.seen != rhs.seen {
            return false
        }
        if lhs.archived != rhs.archived {
            return false
        }
        if lhs.category != rhs.category {
            return false
        }
        if lhs.topic != rhs.topic {
            return false
        }
        return true
    }
}

extension StorePredicate {
    func match(_ notification: Notification) -> Bool {
        let validator = NotificationValidator(predicate: self)
        return validator.validate(notification)
    }
}
