//
//  StorePredicateValidator.swift
//  MagicBellTests
//
//  Created by Javi on 30/11/21.
//

import XCTest
@testable import MagicBell
import struct MagicBell.Notification
import Nimble

class NotificationValidatorTests: XCTestCase {

    func allNotifications(
        read: Bool? = nil,
        seen: Bool? = nil,
        archived: Bool? = nil,
        category: String? = nil,
        topic: String? = nil
    ) -> [Notification] {
        let readValues: [Bool] = {
            if let read = read {
                return [read]
            } else {
                // If seen is false it cannot be read
                if let seen = seen, seen == false {
                    return [false]
                } else {
                    return [true, false]
                }
            }
        }()
        let seenValues: [Bool] = {
            if let seen = seen {
                return [seen]
            } else {
                return [true, false]
            }
        }()
        let archivedValues: [Bool] = {
            if let archived = archived {
                return [archived]
            } else {
                return [true, false]
            }
        }()
        let categoryValues: [String] = {
            if let category = category {
                return [category]
            } else {
                return ["nil", "category"]
            }
        }()
        let topicValues: [String] = {
            if let topic = topic {
                return [topic]
            } else {
                return ["nil", "topic"]
            }
        }()

        var notifications: [Notification] = []
        for read in readValues {
            for seen in seenValues {
                for archived in archivedValues {
                    for category in categoryValues {
                        for topic in topicValues {
                            notifications.append(
                                Notification.create(
                                    read: read,
                                    seen: seen,
                                    archived: archived,
                                    category: category == "nil" ? nil : category,
                                    topic: topic == "nil" ? nil : topic
                                )
                            )
                        }
                    }
                }
            }
        }
        return notifications
    }

    func test_predicate_all() throws {
        let predicate = StorePredicate()
        for notification in allNotifications() {
            expect(predicate.match(notification)) == true
        }
    }

    func test_predicate_read() throws {
        let predicate = StorePredicate(read: .read)
        for notification in allNotifications(read: true) {
            expect(predicate.match(notification)) == true
        }
        for notification in allNotifications(read: false) {
            expect(predicate.match(notification)) == false
        }
    }

    func test_predicate_unread() throws {
        let predicate = StorePredicate(read: .unread)
        for notification in allNotifications(read: false) {
            expect(predicate.match(notification)) == true
        }
        for notification in allNotifications(read: true) {
            expect(predicate.match(notification)) == false
        }
    }

    func test_predicate_seen() throws {
        let predicate = StorePredicate(seen: .seen)
        for notification in allNotifications(seen: true) {
            expect(predicate.match(notification)) == true
        }
        for notification in allNotifications(seen: false) {
            expect(predicate.match(notification)) == false
        }
    }

    func test_predicate_unseen() throws {
        let predicate = StorePredicate(seen: .unseen)
        for notification in allNotifications(seen: false) {
            expect(predicate.match(notification)) == true
        }
        for notification in allNotifications(seen: true) {
            expect(predicate.match(notification)) == false
        }
    }

    func test_predicate_archived() throws {
        let predicate = StorePredicate(archived: .archived)
        for notification in allNotifications(archived: true) {
            expect(predicate.match(notification)) == true
        }
        for notification in allNotifications(archived: false) {
            expect(predicate.match(notification)) == false
        }
    }

    func test_predicate_unarchived() throws {
        let predicate = StorePredicate(archived: .unarchived)
        for notification in allNotifications(archived: false) {
            expect(predicate.match(notification)) == true
        }
        for notification in allNotifications(archived: true) {
            expect(predicate.match(notification)) == false
        }
    }

    func test_predicate_category() throws {
        let predicate = StorePredicate(categories: ["the-category"])
        for notification in allNotifications(category: "the-category") {
            expect(predicate.match(notification)) == true
        }
        for notification in allNotifications(category: "not-the-category") {
            expect(predicate.match(notification)) == false
        }
        for notification in allNotifications(category: "nil") {
            expect(predicate.match(notification)) == false
        }
    }

    func test_predicate_topic() throws {
        let predicate = StorePredicate(topics: ["the-topic"])
        for notification in allNotifications(topic: "the-topic") {
            expect(predicate.match(notification)) == true
        }
        for notification in allNotifications(topic: "not-the-topic") {
            expect(predicate.match(notification)) == false
        }
        for notification in allNotifications(topic: "nil") {
            expect(predicate.match(notification)) == false
        }
    }
}
