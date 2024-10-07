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

import XCTest
@testable import MagicBell
import struct MagicBell.Notification
import Nimble

class NotificationValidatorTests: XCTestCase {

    func allNotifications(
        read: Bool? = nil,
        seen: Bool? = nil,
        archived: Bool = false,
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

        let archivedValues: [Bool] = [archived]

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
        let predicate = StorePredicate(read: true)
        for notification in allNotifications(read: true) {
            expect(predicate.match(notification)) == true
        }
        for notification in allNotifications(read: false) {
            expect(predicate.match(notification)) == false
        }
    }

    func test_predicate_unread() throws {
        let predicate = StorePredicate(read: false)
        for notification in allNotifications(read: false) {
            expect(predicate.match(notification)) == true
        }
        for notification in allNotifications(read: true) {
            expect(predicate.match(notification)) == false
        }
    }

    func test_predicate_seen() throws {
        let predicate = StorePredicate(seen: true)
        for notification in allNotifications(seen: true) {
            expect(predicate.match(notification)) == true
        }
        for notification in allNotifications(seen: false) {
            expect(predicate.match(notification)) == false
        }
    }

    func test_predicate_unseen() throws {
        let predicate = StorePredicate(seen: false)
        for notification in allNotifications(seen: false) {
            expect(predicate.match(notification)) == true
        }
        for notification in allNotifications(seen: true) {
            expect(predicate.match(notification)) == false
        }
    }

    func test_predicate_archived() throws {
        let predicate = StorePredicate(archived: true)
        for notification in allNotifications(archived: true) {
            expect(predicate.match(notification)) == true
        }
        for notification in allNotifications(archived: false) {
            expect(predicate.match(notification)) == false
        }
    }

    func test_predicate_unarchived() throws {
        let predicate = StorePredicate(archived: false)
        for notification in allNotifications(archived: false) {
            expect(predicate.match(notification)) == true
        }
        for notification in allNotifications(archived: true) {
            expect(predicate.match(notification)) == false
        }
    }

    func test_predicate_category() throws {
        let predicate = StorePredicate(category: "the-category")
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
        let predicate = StorePredicate(topic: "the-topic")
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
