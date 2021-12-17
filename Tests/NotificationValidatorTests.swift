//
//  StorePredicateValidator.swift
//  MagicBellTests
//
//  Created by Javi on 30/11/21.
//

import XCTest
@testable import MagicBell
import struct MagicBell.Notification

class NotificationValidatorTests: XCTestCase {

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    private func notification(
        read: Bool = false,
        seen: Bool = false,
        archived: Bool = false,
        category: String? = nil,
        topic: String? = nil
    ) -> Notification {
        Notification(
            id: "123456789",
            title: "Testing",
            actionURL: nil,
            content: "Lorem ipsum sir dolor amet",
            category: category,
            topic: topic,
            customAttributes: nil,
            recipient: nil,
            seenAt: seen ? Date() : nil,
            sentAt: Date(),
            readAt: read ? Date() : nil,
            archivedAt: archived ? Date() : nil
        )
    }

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
                return [true, false]
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
                                notification(
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
            XCTAssertTrue(predicate.match(notification))
        }
    }

    func test_predicate_read() throws {
        let predicate = StorePredicate(read: .read)
        for notification in allNotifications(read: true) {
            XCTAssertTrue(predicate.match(notification))
        }
        for notification in allNotifications(read: false) {
            XCTAssertFalse(predicate.match(notification))
        }
    }

    func test_predicate_unread() throws {
        let predicate = StorePredicate(read: .unread)
        for notification in allNotifications(read: false) {
            XCTAssertTrue(predicate.match(notification))
        }
        for notification in allNotifications(read: true) {
            XCTAssertFalse(predicate.match(notification))
        }
    }

    func test_predicate_seen() throws {
        let predicate = StorePredicate(seen: .seen)
        for notification in allNotifications(seen: true) {
            XCTAssertTrue(predicate.match(notification))
        }
        for notification in allNotifications(seen: false) {
            XCTAssertFalse(predicate.match(notification))
        }
    }

    func test_predicate_unseen() throws {
        let predicate = StorePredicate(seen: .unseen)
        for notification in allNotifications(seen: false) {
            XCTAssertTrue(predicate.match(notification))
        }
        for notification in allNotifications(seen: true) {
            XCTAssertFalse(predicate.match(notification))
        }
    }

    func test_predicate_archived() throws {
        let predicate = StorePredicate(archived: .archived)
        for notification in allNotifications(archived: true) {
            XCTAssertTrue(predicate.match(notification))
        }
        for notification in allNotifications(archived: false) {
            XCTAssertFalse(predicate.match(notification))
        }
    }

    func test_predicate_unarchived() throws {
        let predicate = StorePredicate(archived: .unarchived)
        for notification in allNotifications(archived: false) {
            XCTAssertTrue(predicate.match(notification))
        }
        for notification in allNotifications(archived: true) {
            XCTAssertFalse(predicate.match(notification))
        }
    }

    func test_predicate_category() throws {
        let predicate = StorePredicate(categories: ["the-category"])
        for notification in allNotifications(category: "the-category") {
            XCTAssertTrue(predicate.match(notification))
        }
        for notification in allNotifications(category: "not-the-category") {
            XCTAssertFalse(predicate.match(notification))
        }
        for notification in allNotifications(category: "nil") {
            XCTAssertFalse(predicate.match(notification))
        }
    }

    func test_predicate_topic() throws {
        let predicate = StorePredicate(topics: ["the-topic"])
        for notification in allNotifications(topic: "the-topic") {
            XCTAssertTrue(predicate.match(notification))
        }
        for notification in allNotifications(topic: "not-the-topic") {
            XCTAssertFalse(predicate.match(notification))
        }
        for notification in allNotifications(topic: "nil") {
            XCTAssertFalse(predicate.match(notification))
        }
    }
}
