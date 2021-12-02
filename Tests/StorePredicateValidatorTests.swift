//
//  StorePredicateValidator.swift
//  MagicBellTests
//
//  Created by Javi on 30/11/21.
//

import XCTest
@testable import MagicBell

class StorePredicateValidatorTests: XCTestCase {

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func test_ValidatePredicate_WithRead_ShouldBeTrue() throws {
        let storePredicateValidatorRead = StorePredicateValidator(storePredicate: StorePredicate(read: .read))
        let notification = Notification(id: "Testing", readAt: Date())

        XCTAssertTrue(storePredicateValidatorRead.validateRead(notification))
    }

    func test_ValidatePredicate_WithUnspecified_ShouldBeTrue() throws {
        let storePredicateValidatorRead = StorePredicateValidator(storePredicate: StorePredicate(read: .unspecified))
        let notification = Notification(id: "Testing", readAt: Date())

        XCTAssertTrue(storePredicateValidatorRead.validateRead(notification))
    }

    func test_ValidatePredicate_WithUnread_ShouldBeTrue() throws {
        let storePredicateValidatorRead = StorePredicateValidator(storePredicate: StorePredicate(read: .unread))
        let notification = Notification(id: "Testing", readAt: nil)

        XCTAssertTrue(storePredicateValidatorRead.validateRead(notification))
    }

    func test_ValidatePredicate_WithUnread_ShouldBeFalse() throws {
        let storePredicateValidatorRead = StorePredicateValidator(storePredicate: StorePredicate(read: .unread))
        let notification = Notification(id: "Testing", readAt: Date())

        XCTAssertFalse(storePredicateValidatorRead.validateRead(notification))
    }

    func test_ValidateSeenPredicate_WithSeenDate_Shoul() throws {
        let storePredicateValidatorRead = StorePredicateValidator(storePredicate: StorePredicate(seen: .seen))
        let notification = Notification(id: "Testing", seenAt: Date())

        XCTAssertTrue(storePredicateValidatorRead.validateSeen(notification))
    }

    func test_should_validate_seen_predicate_unspecified() throws {
        let storePredicateValidatorRead = StorePredicateValidator(storePredicate: StorePredicate(seen: .unspecified))
        let notification = Notification(id: "Testing", seenAt: Date())

        XCTAssertTrue(storePredicateValidatorRead.validateSeen(notification))
    }

    func test_should_validate_seen_unseen() throws {
        let storePredicateValidatorRead = StorePredicateValidator(storePredicate: StorePredicate(seen: .unseen))
        let notification = Notification(id: "Testing", seenAt: Date())

        XCTAssertTrue(storePredicateValidatorRead.validateSeen(notification))
    }

    func test_should_validate_archive_predicate() throws {
        let storePredicateValidatorRead = StorePredicateValidator(storePredicate: StorePredicate(archived: .archived))
        let notification = Notification(id: "Testing", archivedAt: Date())

        XCTAssertTrue(storePredicateValidatorRead.validateArchive(notification))
    }

    func test_should_validate_category_predicate() throws {
        let storePredicateValidatorRead = StorePredicateValidator(storePredicate: StorePredicate(categories: ["Test"]))
        let notification = Notification(id: "Testing", category: "Test")

        XCTAssertTrue(storePredicateValidatorRead.validateCategory(notification))
    }

    func test_should_validate_topic_predicate() throws {
        let storePredicateValidatorRead = StorePredicateValidator(storePredicate: StorePredicate(topics: ["Test"]))
        let notification = Notification(id: "Testing", topic: "Test")

        XCTAssertTrue(storePredicateValidatorRead.validateTopic(notification))
    }

    func test_should_validate_inApp_predicate() throws {
        let storePredicateValidatorRead = StorePredicateValidator(storePredicate: StorePredicate(inApp: "Test"))
        let notification = Notification(id: "Testing", topic: "Test")

        XCTAssertTrue(storePredicateValidatorRead.validateInApp(notification))
    }
}
