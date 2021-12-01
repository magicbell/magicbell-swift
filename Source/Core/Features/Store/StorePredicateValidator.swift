//
//  StorePredicateValidator.swift
//  MagicBell
//
//  Created by Javi on 30/11/21.
//

import Foundation

struct StorePredicateValidator {
    let storePredicate: StorePredicate

    func validateNotification(_ notification: Notification) -> Bool {
        return validateRead(notification) &&
        validateSeen(notification) &&
        validateArchive(notification) &&
        validateCategory(notification) &&
        validateTopic(notification) &&
        validateInApp(notification)
    }

    func validateRead(_ notification: Notification) -> Bool {
        if storePredicate.read == .read && notification.readAt != nil {
            return true
        } else if storePredicate.read == .unread && notification.readAt == nil {
            return true
        } else if storePredicate.read == .unspecified {
            return true
        } else {
            return false
        }
    }

    func validateSeen(_ notification: Notification) -> Bool {
        if storePredicate.seen == .seen && notification.seenAt != nil {
            return true
        } else if storePredicate.seen == .unseen && notification.seenAt == nil {
            return true
        } else if storePredicate.seen == .unspecified {
            return true
        } else {
            return false
        }
    }

    func validateArchive(_ notification: Notification) -> Bool {
        if storePredicate.archived == .archived && notification.archivedAt != nil {
            return true
        } else if storePredicate.archived == .unarchived && notification.archivedAt == nil {
            return true
        } else if storePredicate.archived == .unspecified {
            return true
        } else {
            return false
        }
    }

    func validateCategory(_ notification: Notification) -> Bool {
        if storePredicate.categories.isEmpty {
            return true
        } else if let category = notification.category {
            return storePredicate.categories.contains(category)
        } else {
            return false
        }
    }

    func validateTopic(_ notification: Notification) -> Bool {
        if storePredicate.topics.isEmpty {
            return true
        } else if let topic = notification.topic {
            return storePredicate.topics.contains(topic)
        } else {
            return false
        }
    }

    func validateInApp(_ notification: Notification) -> Bool {
        true
    }
}
