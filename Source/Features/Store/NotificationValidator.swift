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

struct NotificationValidator {
    let predicate: StorePredicate

    func validate(_ notification: Notification) -> Bool {
        return validateRead(notification) &&
        validateSeen(notification) &&
        validateArchive(notification) &&
        validateCategory(notification) &&
        validateTopic(notification)
    }

    func validateRead(_ notification: Notification) -> Bool {
        if predicate.read == true && notification.readAt != nil {
            return true
        } else if predicate.read == false && notification.readAt == nil {
            return true
        } else if predicate.read == nil {
            return true
        } else {
            return false
        }
    }

    func validateSeen(_ notification: Notification) -> Bool {
        if predicate.seen == true && notification.seenAt != nil {
            return true
        } else if predicate.seen == false && notification.seenAt == nil {
            return true
        } else if predicate.seen == nil {
            return true
        } else {
            return false
        }
    }

    func validateArchive(_ notification: Notification) -> Bool {
        if predicate.archived == true && notification.archivedAt != nil {
            return true
        } else if predicate.archived == false && notification.archivedAt == nil {
            return true
        } else {
            return false
        }
    }

    func validateCategory(_ notification: Notification) -> Bool {
        if predicate.category == nil {
            return true
        } else if let category = notification.category {
            return predicate.category == category
        } else {
            return false
        }
    }

    func validateTopic(_ notification: Notification) -> Bool {
        if predicate.topic == nil {
            return true
        } else if let topic = notification.topic {
            return predicate.topic == topic
        } else {
            return false
        }
    }
}
