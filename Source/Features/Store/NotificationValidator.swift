//
//  StorePredicateValidator.swift
//  MagicBell
//
//  Created by Javi on 30/11/21.
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
        if predicate.read == .read && notification.readAt != nil {
            return true
        } else if predicate.read == .unread && notification.readAt == nil {
            return true
        } else if predicate.read == .unspecified {
            return true
        } else {
            return false
        }
    }

    func validateSeen(_ notification: Notification) -> Bool {
        if predicate.seen == .seen && notification.seenAt != nil {
            return true
        } else if predicate.seen == .unseen && notification.seenAt == nil {
            return true
        } else if predicate.seen == .unspecified {
            return true
        } else {
            return false
        }
    }

    func validateArchive(_ notification: Notification) -> Bool {
        if predicate.archived == .archived && notification.archivedAt != nil {
            return true
        } else if predicate.archived == .unarchived && notification.archivedAt == nil {
            return true
        } else if predicate.archived == .unspecified {
            return true
        } else {
            return false
        }
    }

    func validateCategory(_ notification: Notification) -> Bool {
        if predicate.categories.isEmpty {
            return true
        } else if let category = notification.category {
            return predicate.categories.contains(category)
        } else {
            return false
        }
    }

    func validateTopic(_ notification: Notification) -> Bool {
        if predicate.topics.isEmpty {
            return true
        } else if let topic = notification.topic {
            return predicate.topics.contains(topic)
        } else {
            return false
        }
    }
}
