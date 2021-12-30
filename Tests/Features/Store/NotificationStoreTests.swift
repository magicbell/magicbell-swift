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

@testable import MagicBell
@testable import Harmony
import struct MagicBell.Notification
import XCTest
import Nimble

class NotificationStoreTests: XCTestCase {
    let defaultEdgeArraySize = 20
    lazy var anyIndexForDefaultEdgeArraySize = Int.random(in: 0..<defaultEdgeArraySize)

    let userQuery = UserQuery(email: "javier@mobilejazz.com")

    var fetchStorePageInteractor: FetchStorePageMockInteractor!
    var actionNotificationInteractor: ActionNotificationMockInteractor!
    var deleteNotificationInteractor: DeleteNotificationMockInteractor!

    var notificationStore: NotificationStore!

    private func createNotificationStore(predicate: StorePredicate,
                                         fetchStoreExpectedResult: Result<StorePage, Error>,
                                         actionStoreExpectedResult: Result<Void, Error> = .success(()),
                                         deleteStoreExpectedResult: Result<Void, Error> = .success(())) -> NotificationStore {
        fetchStorePageInteractor = FetchStorePageMockInteractor(expectedResult: fetchStoreExpectedResult)
        actionNotificationInteractor = ActionNotificationMockInteractor(expectedResult: actionStoreExpectedResult)
        deleteNotificationInteractor = DeleteNotificationMockInteractor(expectedResult: deleteStoreExpectedResult)

        notificationStore = NotificationStore(
            predicate: predicate,
            userQuery: userQuery,
            fetchStorePageInteractor: fetchStorePageInteractor,
            actionNotificationInteractor: actionNotificationInteractor,
            deleteNotificationInteractor: deleteNotificationInteractor,
            logger: DeviceConsoleLogger())

        return notificationStore
    }

    func test_init_shouldReturnEmptyNotifications() {
        let predicate = StorePredicate()
        let store = createNotificationStore(
            predicate: StorePredicate(),
            fetchStoreExpectedResult: .success(givenPageStore(predicate: predicate, size: defaultEdgeArraySize))
        )
        expect(store.count).to(equal(0))
    }

    func test_fetch_withDefaultStorePredicate_shouldReturnNotification() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize)
        let store = createNotificationStore(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        let expectation = expectation(description: "FetchNotifications")
        var notifications: [Notification] = []
        store.fetch { result in
            notifications = try! result.get()
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        // THEN
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(1))
        expect(store.count).to(equal(defaultEdgeArraySize))
        storePage.edges.enumerated().forEach { idx, edge in
            expect(store[idx].id).to(equal(edge.node.id))
        }

        expect(notifications.count).to(equal(defaultEdgeArraySize))
        storePage.edges.enumerated().forEach { idx, edge in
            expect(notifications[idx].id).to(equal(edge.node.id))
        }
    }

    func test_store_allNotifications_shouldReturnAllNotifications() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize)
        let store = createNotificationStore(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        let expectation = expectation(description: "FetchNotifications")
        store.fetch { _ in expectation.fulfill() }
        waitForExpectations(timeout: 1, handler: nil)

        // THEN
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(1))
        expect(store.count).to(equal(defaultEdgeArraySize))
        expect(storePage.edges.map { $0.node.id }).to(equal(store.notifications().map { $0.id }))
    }

    func test_fetch_withDefaultStorePredicateAndError_shouldReturnError() {
        // GIVEN
        let predicate = StorePredicate()
        let store = createNotificationStore(
            predicate: predicate,
            fetchStoreExpectedResult: .failure(MagicBellError("Error"))
        )

        // WHEN
        let expectation = expectation(description: "FetchNotifications")
        var errorExpected: Error?
        store.fetch { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                errorExpected = error
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        // THEN
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(1))
        expect(store.count).to(equal(0))
        expect(errorExpected).toNot(beNil())
    }

    func test_refresh_withDefaultStorePredicate_shouldRefreshContent() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize)
        let store = createNotificationStore(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        let expectation = expectation(description: "RefreshNotification")
        var notifications: [Notification] = []
        store.refresh { result in
            notifications = try! result.get()
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        // THEN
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(1))
        expect(store.count).to(equal(defaultEdgeArraySize))
        storePage.edges.enumerated().forEach { idx, edge in
            expect(store[idx].id).to(equal(edge.node.id))
        }

        expect(notifications.count).to(equal(defaultEdgeArraySize))
        storePage.edges.enumerated().forEach { idx, edge in
            expect(notifications[idx].id).to(equal(edge.node.id))
        }
    }

    func test_refresh_withDefaultStorePredicateAndError_shouldReturnError() {
        // GIVEN
        let predicate = StorePredicate()
        let store = createNotificationStore(
            predicate: predicate,
            fetchStoreExpectedResult: .failure(MagicBellError("Error"))
        )

        // WHEN
        let expectation = expectation(description: "RefreshNotifications")
        var errorExpected: Error?
        store.refresh { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                errorExpected = error
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        // THEN
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(1))
        expect(store.count).to(equal(0))
        expect(errorExpected).toNot(beNil())
    }

    func test_fetch_withPagination_shouldReturnTwoNotificationPages() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = StorePage.create(
            edges: anyNotificationEdgeArray(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .none),
            pageInfo: PageInfo.create(endCursor: AnyCursor.any.rawValue, hasNextPage: true)
        )
        let store = createNotificationStore(predicate: predicate, fetchStoreExpectedResult: .success(storePage))

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotifications")
        store.fetch { _ in  expectation.fulfill() }
        wait(for: [expectation], timeout: 1)

        // THEN
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(1))
        expect(store.count).to(equal(defaultEdgeArraySize))

        // WHEN
        let expectationSecondPage = XCTestExpectation(description: "FetchNotifications")
        var notifications: [Notification] = []
        store.fetch { result in
            notifications = try! result.get()
            expectationSecondPage.fulfill()
        }
        wait(for: [expectationSecondPage], timeout: 1)

        // THEN
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(2))
        expect(store.count).to(equal(defaultEdgeArraySize * self.fetchStorePageInteractor.executeCounter))
        storePage.edges.enumerated().forEach { idx, edge in
            expect(store[idx].id) == edge.node.id
        }
        expect(notifications.count).to(equal(defaultEdgeArraySize))
        storePage.edges.enumerated().forEach { idx, edge in
            expect(notifications[idx].id).to(equal(edge.node.id))
        }
    }

    func test_fetch_withoutPagination_shouldReturnEmptyArray() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = StorePage.create(
            edges: anyNotificationEdgeArray(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .none),
            pageInfo: PageInfo.create(endCursor: AnyCursor.any.rawValue, hasNextPage: false)
        )
        let store = createNotificationStore(predicate: predicate, fetchStoreExpectedResult: .success(storePage))

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotifications")
        store.fetch { _ in  expectation.fulfill() }
        wait(for: [expectation], timeout: 1)

        // THEN
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(1))
        expect(store.count).to(equal(defaultEdgeArraySize))

        // WHEN
        let expectationSecondPage = XCTestExpectation(description: "FetchNotifications")
        var notifications: [Notification] = []
        store.fetch { result in
            notifications = try! result.get()
            expectationSecondPage.fulfill()
        }
        wait(for: [expectationSecondPage], timeout: 1)

        // THEN
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(1))
        expect(store.count).to(equal(defaultEdgeArraySize))
        storePage.edges.enumerated().forEach { idx, edge in
            expect(store[idx].id) == edge.node.id
        }
        expect(notifications.count).to(equal(0))
    }

    func test_refresh_twoTimes_shouldReturnSamePage() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize)
        let store = createNotificationStore(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        let expectation = XCTestExpectation(description: "RefreshNotifications")
        store.refresh { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)

        // THEN
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(1))
        expect(store.count).to(equal(defaultEdgeArraySize))
        storePage.edges.enumerated().forEach { idx, edge in
            expect(store[idx].id).to(equal(edge.node.id))
        }

        // WHEN
        let expectationSecond = XCTestExpectation(description: "RefreshNotifications")
        store.refresh { _ in expectationSecond.fulfill()}
        wait(for: [expectationSecond], timeout: 1)

        // THEN
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(2))
        expect(store.count).to(equal(defaultEdgeArraySize))
        storePage.edges.enumerated().forEach { idx, edge in
            expect(store[idx].id).to(equal(edge.node.id))
        }
    }

    func test_fetch_withPageInfoHasNextPageTrue_shouldConfigurePaginationTrue() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = StorePage.create(
            edges: anyNotificationEdgeArray(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .none),
            pageInfo: PageInfo.create(endCursor: AnyCursor.any.rawValue, hasNextPage: true)
        )
        let store = createNotificationStore(predicate: predicate, fetchStoreExpectedResult: .success(storePage))
        expect(store.hasNextPage).to(beTrue())

        // WHEN
        let expectation = expectation(description: "FetchNotifications")
        store.fetch { _ in expectation.fulfill() }
        waitForExpectations(timeout: 1, handler: nil)

        // THEN
        expect(store.hasNextPage).to(beTrue())
    }

    func test_fetch_withPageInfoHasNextPageFalse_shouldConfigurePaginationFalse() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = StorePage.create(
            edges: anyNotificationEdgeArray(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .none),
            pageInfo: PageInfo.create(endCursor: AnyCursor.any.rawValue, hasNextPage: false)
        )
        let store = createNotificationStore(predicate: predicate, fetchStoreExpectedResult: .success(storePage))
        expect(store.hasNextPage).to(equal(true))

        // WHEN
        let expectation = expectation(description: "FetchNotifications")
        store.fetch { _ in expectation.fulfill() }
        waitForExpectations(timeout: 1, handler: nil)

        // THEN
        expect(store.hasNextPage).to(beFalse())
    }

    func test_refresh_withPageInfoHasNextPageFalse_shouldConfigurePaginationFalse() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = StorePage.create(
            edges: anyNotificationEdgeArray(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .none),
            pageInfo: PageInfo.create(endCursor: nil, hasNextPage: false)
        )
        let store = createNotificationStore(predicate: predicate, fetchStoreExpectedResult: .success(storePage))
        expect(store.hasNextPage).to(beTrue())

        // WHEN
        let expectationSecond = XCTestExpectation(description: "RefreshNotifications")
        store.refresh { _ in expectationSecond.fulfill()}
        wait(for: [expectationSecond], timeout: 1)

        // THEN
        expect(store.hasNextPage).to(beFalse())
    }

    func test_deleteNotification_withDefaultStorePredicate_shouldCallActionNotificationInteractor() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .read)
        let store = createNotificationStore(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotifications")
        store.fetch { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        let removeIndex = anyIndexForDefaultEdgeArraySize
        let removedNotification = store[removeIndex]
        let expectationDelete = XCTestExpectation(description: "DeleteNotifications")
        store.delete(store[removeIndex]) { _ in  expectationDelete.fulfill() }
        wait(for: [expectationDelete], timeout: 1)

        // THEN
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(1))
        expect(self.deleteNotificationInteractor.executeCounter).to(equal(1))
        expect(self.deleteNotificationInteractor.executeParamsSpy[0].notificationId).to(equal(removedNotification.id))
    }

    func test_deleteNotification_withError_shouldReturnError() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .read)
        let store = createNotificationStore(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage),
            deleteStoreExpectedResult: .failure(MagicBellError("Error"))
        )

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotifications")
        store.fetch { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        let removeIndex = anyIndexForDefaultEdgeArraySize
        let removedNotification = store[removeIndex]
        let expectationDelete = XCTestExpectation(description: "DeleteNotifications")
        var errorExpected: Error?
        store.delete(store[removeIndex]) { error in
            switch error {
            case .none:
                break
            case .some(let error):
                errorExpected = error
            }
            expectationDelete.fulfill()
        }
        wait(for: [expectationDelete], timeout: 1)

        // THEN
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(1))
        expect(self.deleteNotificationInteractor.executeCounter).to(equal(1))
        expect(self.deleteNotificationInteractor.executeParamsSpy[0].notificationId).to(equal(removedNotification.id))
        expect(errorExpected).toNot(beNil())
    }

    func test_deleteNotification_withDefaultStorePredicateAndReadNotification_shouldRemoveNotificationAndSameUnreadCount() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .read)
        let store = createNotificationStore(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotifications")
        store.fetch { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        let initialCounts = InitialNotificationStoreCounts(store)
        let removeIndex = anyIndexForDefaultEdgeArraySize
        let removedNotification = store[removeIndex]
        let expectationDelete = XCTestExpectation(description: "DeleteNotifications")
        store.delete(store[removeIndex]) { _ in  expectationDelete.fulfill()}
        wait(for: [expectationDelete], timeout: 1)

        // THEN
        expect(store.totalCount).to(equal(initialCounts.totalCount - 1))
        expect(store.unreadCount).to(equal(initialCounts.unreadCount))
        if store.count > removeIndex {
            expect(store[removeIndex].id).toNotEventually(equal(removedNotification.id))
        }
    }

    func test_deleteNotification_withDefaultStorePredicateAndUnreadNotification_shouldRemoveNotificationAndDifferentUnreadCount() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .unread)
        let store = createNotificationStore(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )
        let expectation = XCTestExpectation(description: "FetchNotifications")
        store.fetch { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)

        let initialCounts = InitialNotificationStoreCounts(store)
        let removeIndex = anyIndexForDefaultEdgeArraySize
        let removedNotification = store[removeIndex]

        // WHEN
        let expectationDelete = XCTestExpectation(description: "DeleteNotifications")
        store.delete(store[removeIndex]) { _ in  expectationDelete.fulfill()}
        wait(for: [expectationDelete], timeout: 1)

        // THEN
        expect(store.totalCount).to(equal(initialCounts.totalCount - 1))
        expect(store.unreadCount).to(equal(initialCounts.unreadCount - 1))
        if store.count > removeIndex {
            expect(store[removeIndex].id).toNotEventually(equal(removedNotification.id))
        }
    }

    func test_deleteNotification_withDefaultStorePredicateAndSeenNotification_shouldRemoveNotificationAndSameUnseenCount() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .seen)
        let store = createNotificationStore(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotifications")
        store.fetch { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        let initialCounts = InitialNotificationStoreCounts(store)
        let removeIndex = anyIndexForDefaultEdgeArraySize
        let removedNotification = store[removeIndex]
        let expectationDelete = XCTestExpectation(description: "DeleteNotifications")
        store.delete(store[removeIndex]) { _ in  expectationDelete.fulfill()}
        wait(for: [expectationDelete], timeout: 1)

        // THEN
        expect(store.totalCount).to(equal(initialCounts.totalCount - 1))
        expect(store.unseenCount).to(equal(initialCounts.unseenCount))
        if store.count > removeIndex {
            expect(store[removeIndex].id).toNotEventually(equal(removedNotification.id))
        }
    }

    func test_deleteNotification_withDefaultStorePredicateAndUnseenNotification_shouldRemoveNotificationAndDifferentUnseenCount() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .unseen)
        let store = createNotificationStore(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotifications")
        store.fetch { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        let initialCounts = InitialNotificationStoreCounts(store)
        let removeIndex = anyIndexForDefaultEdgeArraySize
        let removedNotification = store[removeIndex]
        let expectationDelete = XCTestExpectation(description: "DeleteNotifications")
        store.delete(store[removeIndex]) { _ in  expectationDelete.fulfill()}
        wait(for: [expectationDelete], timeout: 1)

        // THEN
        expect(store.totalCount).to(equal(initialCounts.totalCount - 1))
        expect(store.unseenCount).to(equal(initialCounts.unseenCount - 1))
        if store.count > removeIndex {
            expect(store[removeIndex].id).toNotEventually(equal(removedNotification.id))
        }
    }

    func test_deleteNotification_withReadStorePredicate_shouldRemoveNotification() {
        // GIVEN
        let predicate = StorePredicate(read: .read)
        let storePage = StorePage.create(
            edges: anyNotificationEdgeArray(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .none),
            pageInfo: anyPageInfo()
        )
        let store = createNotificationStore(predicate: predicate, fetchStoreExpectedResult: .success(storePage))

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        expect(store.count).to(equal(defaultEdgeArraySize))
        let initialCounts = InitialNotificationStoreCounts(store)
        let removeIndex = anyIndexForDefaultEdgeArraySize
        let expectationDelete = XCTestExpectation(description: "DeleteNotification")
        store.delete(store[removeIndex]) { _ in expectationDelete.fulfill()}
        wait(for: [expectationDelete], timeout: 1)

        // THEN
        expect(store.totalCount).to(equal(initialCounts.totalCount - 1))
        expect(store.unreadCount).to(equal(0))
    }

    func test_deleteNotification_withUnreadStorePredicate_shouldRemoveNotification() {
        // GIVEN
        let predicate = StorePredicate(read: .unread)
        let storePage = StorePage.create(
            edges: anyNotificationEdgeArray(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .unread),
            pageInfo: anyPageInfo()
        )
        let store = createNotificationStore(predicate: predicate, fetchStoreExpectedResult: .success(storePage))

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        expect(store.count).to(equal(defaultEdgeArraySize))
        let initialCounts = InitialNotificationStoreCounts(store)
        let removeIndex = anyIndexForDefaultEdgeArraySize
        let expectationDelete = XCTestExpectation(description: "DeleteNotification")
        store.delete(store[removeIndex]) { _ in expectationDelete.fulfill()}
        wait(for: [expectationDelete], timeout: 1)

        // THEN
        expect(store.totalCount).to(equal(initialCounts.totalCount - 1))
        expect(store.unreadCount).to(equal(initialCounts.unreadCount - 1))
    }

    func test_deleteNotification_withUnreadStorePredicateWithUnseenNotifications_shouldRemoveNotificationAndUpdateUnseeCount() {
        // GIVEN
        let predicate = StorePredicate(read: .unread)
        let storePage = StorePage.create(
            edges: anyNotificationEdgeArray(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .unseen),
            pageInfo: anyPageInfo()
        )
        let store = createNotificationStore(predicate: predicate, fetchStoreExpectedResult: .success(storePage))

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        expect(store.count).to(equal(defaultEdgeArraySize))
        let initialCounts = InitialNotificationStoreCounts(store)
        let removeIndex = anyIndexForDefaultEdgeArraySize
        let expectationDelete = XCTestExpectation(description: "DeleteNotification")
        store.delete(store[removeIndex]) { _ in expectationDelete.fulfill()}
        wait(for: [expectationDelete], timeout: 1)

        // THEN
        expect(store.totalCount).to(equal(initialCounts.totalCount - 1))
        expect(store.unreadCount).to(equal(initialCounts.unreadCount - 1))
        expect(store.unseenCount).to(equal(initialCounts.unseenCount - 1))
    }

    func test_deleteNotification_withUnreadStorePredicateWithSeenNotifications_shouldRemoveNotificationAndSameUnseenCount() {
        // GIVEN
        let predicate = StorePredicate(read: .unread)
        let storePage = StorePage.create(
            edges: anyNotificationEdgeArray(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .seen),
            pageInfo: anyPageInfo()
        )
        let store = createNotificationStore(predicate: predicate, fetchStoreExpectedResult: .success(storePage))

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        expect(store.count).to(equal(defaultEdgeArraySize))

        let initialCounts = InitialNotificationStoreCounts(store)
        let removeIndex = anyIndexForDefaultEdgeArraySize
        let expectationDelete = XCTestExpectation(description: "DeleteNotification")
        store.delete(store[removeIndex]) { _ in expectationDelete.fulfill()}
        wait(for: [expectationDelete], timeout: 1)

        // THEN
        expect(store.totalCount).to(equal(initialCounts.totalCount - 1))
        expect(store.unreadCount).to(equal(initialCounts.unreadCount - 1))
        expect(store.unseenCount).to(equal(initialCounts.unseenCount))
    }

    func test_markNotificationAsRead_withDefaultStorePredicate_shouldCallActioNotificationInteractor() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize)
        let store = createNotificationStore(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        let chosenIndex = anyIndexForDefaultEdgeArraySize
        let markReadNotification = store[chosenIndex]
        let expectationMarkAsRead = XCTestExpectation(description: "MarkAsRead")
        store.markAsRead(store[chosenIndex]) { _ in  expectationMarkAsRead.fulfill()}
        wait(for: [expectationMarkAsRead], timeout: 1)

        // THEN
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(1))
        expect(self.actionNotificationInteractor.executeCounter).to(equal(1))
        expect(self.actionNotificationInteractor.executeParamsSpy[0].notificationId).to(equal(markReadNotification.id))
        expect(self.actionNotificationInteractor.executeParamsSpy[0].action).to(equal(.markAsRead))
    }

    func test_markNotificationAsRead_withError_shouldReturnError() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize)
        let store = createNotificationStore(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage),
            actionStoreExpectedResult: .failure(MagicBellError("Error"))
        )

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        let chosenIndex = anyIndexForDefaultEdgeArraySize
        let markReadNotification = store[chosenIndex]
        let expectationMarkAsRead = XCTestExpectation(description: "MarkAsRead")
        var errorExpected: Error?
        store.markAsRead(store[chosenIndex]) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                errorExpected = error
            }

            expectationMarkAsRead.fulfill()
        }
        wait(for: [expectationMarkAsRead], timeout: 1)

        // THEN
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(1))
        expect(self.actionNotificationInteractor.executeCounter).to(equal(1))
        expect(self.actionNotificationInteractor.executeParamsSpy[0].notificationId).to(equal(markReadNotification.id))
        expect(self.actionNotificationInteractor.executeParamsSpy[0].action).to(equal(.markAsRead))
        expect(errorExpected).toNot(beNil())
    }

    func test_markNotificationAsRead_withDefaultStorePredicate_shouldMarkAsReadNotification() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize)
        let store = createNotificationStore(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        let initialCounts = InitialNotificationStoreCounts(store)
        let chosenIndex = anyIndexForDefaultEdgeArraySize
        let expectationMarkAsRead = XCTestExpectation(description: "MarkAsRead")
        store.markAsRead(store[chosenIndex]) { _ in  expectationMarkAsRead.fulfill()}
        wait(for: [expectationMarkAsRead], timeout: 1)

        // THEN
        expect(store[chosenIndex].readAt).toNot(beNil())
        expect(store.totalCount).to(equal(initialCounts.totalCount))
    }

    func test_markNotificationAsRead_withDefaultStorePredicateAndUnreadNotification_shouldMarkAsReadNotificationAndUpdateUnreadCounter() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .unread)
        let store = createNotificationStore(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        let initialCounts = InitialNotificationStoreCounts(store)
        let chosenIndex = anyIndexForDefaultEdgeArraySize

        let expectationMarkAsRead = XCTestExpectation(description: "MarkAsRead")
        store.markAsRead(store[chosenIndex]) { _ in  expectationMarkAsRead.fulfill()}
        wait(for: [expectationMarkAsRead], timeout: 1)

        // THEN
        expect(store[chosenIndex].readAt).toNot(beNil())
        expect(store.totalCount).to(equal(initialCounts.totalCount))
        expect(store.unreadCount).to(equal(initialCounts.unreadCount - 1))
    }

    func test_markNotificationAsRead_withDefaultStorePredicateAndReadNotification_shouldMarkAsReadNotificationAndSameUnreadCounter() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .read)
        let store = createNotificationStore(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        let initialCounts = InitialNotificationStoreCounts(store)
        let chosenIndex = anyIndexForDefaultEdgeArraySize

        let expectationMarkAsRead = XCTestExpectation(description: "MarkAsRead")
        store.markAsRead(store[chosenIndex]) { _ in  expectationMarkAsRead.fulfill()}
        wait(for: [expectationMarkAsRead], timeout: 1)

        // THEN
        expect(store[chosenIndex].readAt).toNot(beNil())
        expect(store.totalCount).to(equal(initialCounts.totalCount))
        expect(store.unreadCount).to(equal(initialCounts.unreadCount))
    }

    func test_markNotificationAsRead_withDefaultStorePredicateAndUnseenNotification_shouldMarkAsReadNotificationAndUpdateUnseenCounter() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .unseen)
        let store = createNotificationStore(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        let initialCounts = InitialNotificationStoreCounts(store)
        let chosenIndex = anyIndexForDefaultEdgeArraySize

        let expectationMarkAsRead = XCTestExpectation(description: "MarkAsRead")
        store.markAsRead(store[chosenIndex]) { _ in  expectationMarkAsRead.fulfill()}
        wait(for: [expectationMarkAsRead], timeout: 1)

        // THEN
        expect(store[chosenIndex].readAt).toNot(beNil())
        expect(store.totalCount).to(equal(initialCounts.totalCount))
        expect(store.unseenCount).to(equal(initialCounts.unseenCount - 1))
    }

    func test_markNotificationAsRead_withDefaultStorePredicateAndSeenNotification_shouldMarkAsReadNotificationAndSameUnseenCounter() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .seen)
        let store = createNotificationStore(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        let initialCounts = InitialNotificationStoreCounts(store)
        let chosenIndex = anyIndexForDefaultEdgeArraySize
        let expectationMarkAsRead = XCTestExpectation(description: "MarkAsRead")
        store.markAsRead(store[chosenIndex]) { _ in  expectationMarkAsRead.fulfill()}
        wait(for: [expectationMarkAsRead], timeout: 1)

        // THEN
        expect(store[chosenIndex].readAt).toNot(beNil())
        expect(store.totalCount).to(equal(initialCounts.totalCount))
        expect(store.unseenCount).to(equal(initialCounts.unseenCount))
    }

    func test_markNotificationAsRead_withUnreadStorePredicate_shouldMarkAsReadNotification() {
        // GIVEN
        let predicate = StorePredicate(read: .unread)
        let storePage = StorePage.create(
            edges: anyNotificationEdgeArray(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .unread),
            pageInfo: anyPageInfo()
        )
        let store = createNotificationStore(predicate: predicate, fetchStoreExpectedResult: .success(storePage))

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        let initialCounts = InitialNotificationStoreCounts(store)
        let chosenIndex = anyIndexForDefaultEdgeArraySize
        let expectationMarkAsRead = XCTestExpectation(description: "MarkAsRead")
        store.markAsRead(store[chosenIndex]) { _ in  expectationMarkAsRead.fulfill()}
        wait(for: [expectationMarkAsRead], timeout: 1)

        // THEN
        expect(store[chosenIndex].readAt).toNot(beNil())
        expect(store.totalCount).to(equal(initialCounts.totalCount - 1))
        expect(store.unreadCount).to(equal(initialCounts.unreadCount - 1))
    }

    func test_markNotificationAsRead_withUnreadStorePredicateAndUnseenNotification_shouldMarkAsReadNotificationAndUpdateUnseenCount() {
        // GIVEN
        let predicate = StorePredicate(read: .unread)
        let storePage = StorePage.create(
            edges: anyNotificationEdgeArray(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .unseen),
            pageInfo: anyPageInfo()
        )
        let store = createNotificationStore(predicate: predicate, fetchStoreExpectedResult: .success(storePage))

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        let initialCounts = InitialNotificationStoreCounts(store)
        let chosenIndex = anyIndexForDefaultEdgeArraySize
        let expectationMarkAsRead = XCTestExpectation(description: "MarkAsRead")
        store.markAsRead(store[chosenIndex]) { _ in  expectationMarkAsRead.fulfill()}
        wait(for: [expectationMarkAsRead], timeout: 1)

        // THEN
        expect(store[chosenIndex].readAt).toNot(beNil())
        expect(store.totalCount).to(equal(initialCounts.totalCount - 1))
        expect(store.unseenCount).to(equal(initialCounts.unseenCount - 1))
    }

    func test_markNotificationAsRead_withUnreadStorePredicateAndSeenNotification_shouldMarkAsReadNotificationAndSameUnseenCount() {
        // GIVEN
        let predicate = StorePredicate(read: .unread)
        let storePage = StorePage.create(
            edges: anyNotificationEdgeArray(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .seen),
            pageInfo: anyPageInfo()
        )
        let store = createNotificationStore(predicate: predicate, fetchStoreExpectedResult: .success(storePage))

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        let initialCounts = InitialNotificationStoreCounts(store)
        let chosenIndex = anyIndexForDefaultEdgeArraySize
        let expectationMarkAsRead = XCTestExpectation(description: "MarkAsRead")
        store.markAsRead(store[chosenIndex]) { _ in  expectationMarkAsRead.fulfill()}
        wait(for: [expectationMarkAsRead], timeout: 1)

        // THEN
        expect(store[chosenIndex].readAt).toNot(beNil())
        expect(store.totalCount).to(equal(initialCounts.totalCount - 1))
        expect(store.unseenCount).to(equal(initialCounts.unseenCount))
    }

    func test_markNotificationAsUnread_withDefaultStorePredicate_shouldCallActioNotificationInteractor() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize)
        let store = createNotificationStore(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        let chosenIndex = anyIndexForDefaultEdgeArraySize
        let markUnreadNotification = store[chosenIndex]
        let expectationMarkAsRead = XCTestExpectation(description: "MarkAsRead")
        store.markAsUnread(store[chosenIndex]) { _ in  expectationMarkAsRead.fulfill()}
        wait(for: [expectationMarkAsRead], timeout: 1)

        // THEN
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(1))
        expect(self.actionNotificationInteractor.executeCounter).to(equal(1))
        expect(self.actionNotificationInteractor.executeParamsSpy[0].notificationId).to(equal(markUnreadNotification.id))
        expect(self.actionNotificationInteractor.executeParamsSpy[0].action).to(equal(.markAsUnread))
    }

    func test_markNotificationAsUnread_withDefaultStorePredicate_shouldMarkAsUnreadNotification() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize)
        let store = createNotificationStore(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        let initialCounts = InitialNotificationStoreCounts(store)
        let chosenIndex = anyIndexForDefaultEdgeArraySize
        let expectationMarkAsUnread = XCTestExpectation(description: "MarkAsUnread")
        store.markAsUnread(store[chosenIndex]) { _ in  expectationMarkAsUnread.fulfill()}
        wait(for: [expectationMarkAsUnread], timeout: 1)

        // THEN
        expect(store[chosenIndex].readAt).to(beNil())
        expect(store.totalCount).to(equal(initialCounts.totalCount))
        expect(store.unseenCount).to(equal(initialCounts.unseenCount))
    }

    func test_markNotificationAsUnread_withDefaultStorePredicateAndReadNotification_shouldMarkAsUnreadNotificationAndUpdateUnreadCount() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .read)
        let store = createNotificationStore(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        let initialCounts = InitialNotificationStoreCounts(store)
        let chosenIndex = anyIndexForDefaultEdgeArraySize
        let expectationMarkAsUnread = XCTestExpectation(description: "MarkAsUnread")
        store.markAsUnread(store[chosenIndex]) { _ in  expectationMarkAsUnread.fulfill()}
        wait(for: [expectationMarkAsUnread], timeout: 1)

        // THEN
        expect(store[chosenIndex].readAt).to(beNil())
        expect(store.totalCount).to(equal(initialCounts.totalCount))
        expect(store.unreadCount).to(equal(initialCounts.unreadCount + 1))
    }

    func test_markNotificationAsUnread_withReadStorePredicate_shouldRemoveNotification() {
        // GIVEN
        let predicate = StorePredicate(read: .read)
        let storePage = StorePage.create(
            edges: anyNotificationEdgeArray(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .read),
            pageInfo: anyPageInfo()
        )
        let store = createNotificationStore(predicate: predicate, fetchStoreExpectedResult: .success(storePage))

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        let initialCounts = InitialNotificationStoreCounts(store)
        let chosenIndex = anyIndexForDefaultEdgeArraySize
        let expectationMarkAsUnread = XCTestExpectation(description: "MarkAsUnread")
        store.markAsUnread(store[chosenIndex]) { _ in  expectationMarkAsUnread.fulfill()}
        wait(for: [expectationMarkAsUnread], timeout: 1)

        // THEN
        expect(store[chosenIndex].readAt).to(beNil())
        expect(store.totalCount).to(equal(initialCounts.totalCount - 1))
        expect(store.unreadCount).to(equal(0))
        expect(store.unseenCount).to(equal(initialCounts.unseenCount))
    }

    func test_markNotificationAsUnread_withUnreadStorePredicate_shouldDoNothing() {
        // GIVEN
        let predicate = StorePredicate(read: .unread)
        let storePage = StorePage.create(
            edges: anyNotificationEdgeArray(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .unread),
            pageInfo: anyPageInfo()
        )
        let store = createNotificationStore(predicate: predicate, fetchStoreExpectedResult: .success(storePage))

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        let initialCounts = InitialNotificationStoreCounts(store)
        let chosenIndex = anyIndexForDefaultEdgeArraySize
        let expectationMarkAsUnread = XCTestExpectation(description: "MarkAsUnread")
        store.markAsUnread(store[chosenIndex]) { _ in  expectationMarkAsUnread.fulfill()}
        wait(for: [expectationMarkAsUnread], timeout: 1)

        // THEN
        expect(store[chosenIndex].readAt).to(beNil())
        expect(store.totalCount).to(equal(initialCounts.totalCount))
        expect(store.unreadCount).to(equal(initialCounts.unreadCount))
        expect(store.unseenCount).to(equal(initialCounts.unseenCount))
    }

    func test_markNotificationAsArchive_withDefaultStorePredicate_shouldCallActioNotificationInteractor() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize)
        let store = createNotificationStore(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        let chosenIndex = anyIndexForDefaultEdgeArraySize
        let archiveNotification = store[chosenIndex]
        let expectationArchive = XCTestExpectation(description: "Archive")
        store.archive(store[chosenIndex]) { _ in  expectationArchive.fulfill()}
        wait(for: [expectationArchive], timeout: 1)

        // THEN
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(1))
        expect(self.actionNotificationInteractor.executeCounter).to(equal(1))
        expect(self.actionNotificationInteractor.executeParamsSpy[0].notificationId).to(equal(archiveNotification.id))
        expect(self.actionNotificationInteractor.executeParamsSpy[0].action).to(equal(.archive))
    }

    func test_markNotificationAsArchive_withDefaultStorePredicate_shouldHaveArchiveDate() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .read)
        let store = createNotificationStore(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        let chosenIndex = anyIndexForDefaultEdgeArraySize
        let expectationArchive = XCTestExpectation(description: "Archive")
        store.archive(store[chosenIndex]) { _ in  expectationArchive.fulfill()}
        wait(for: [expectationArchive], timeout: 1)

        //THEN
        expect(store[chosenIndex].archivedAt).toNot(beNil())
    }

    func test_markNotificationAsUnarchive_withDefaultStorePredicate_shouldCallActioNotificationInteractor() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize)
        let store = createNotificationStore(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        let chosenIndex = anyIndexForDefaultEdgeArraySize
        let unarchiveNotification = store[chosenIndex]
        let expectationArchive = XCTestExpectation(description: "Unarchive")
        store.unarchive(store[chosenIndex]) { _ in  expectationArchive.fulfill()}
        wait(for: [expectationArchive], timeout: 1)

        // THEN
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(1))
        expect(self.actionNotificationInteractor.executeCounter).to(equal(1))
        expect(self.actionNotificationInteractor.executeParamsSpy[0].notificationId).to(equal(unarchiveNotification.id))
        expect(self.actionNotificationInteractor.executeParamsSpy[0].action).to(equal(.unarchive))
    }

    func test_markNotificationUnarchive_withDefaultStorePredicate_shouldHaveNilArchiveDate() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .read)
        let store = createNotificationStore(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        let chosenIndex = anyIndexForDefaultEdgeArraySize
        let expectationArchive = XCTestExpectation(description: "Unarchive")
        store.unarchive(store[chosenIndex]) { _ in  expectationArchive.fulfill()}
        wait(for: [expectationArchive], timeout: 1)

        //THEN
        expect(store[chosenIndex].archivedAt).to(beNil())
    }

    func test_markNotificationAllRead_withDefaultStorePredicate_shouldCallActioNotificationInteractor() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize)
        let store = createNotificationStore(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        let expectationMarkAllRead = XCTestExpectation(description: "MarkAllRead")
        store.markAllRead { _ in  expectationMarkAllRead.fulfill()}
        wait(for: [expectationMarkAllRead], timeout: 1)

        // THEN
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(1))
        expect(self.actionNotificationInteractor.executeCounter).to(equal(1))
        expect(self.actionNotificationInteractor.executeParamsSpy[0].notificationId).to(beNil())
        expect(self.actionNotificationInteractor.executeParamsSpy[0].action).to(equal(.markAllAsRead))
    }

    func test_markNotificationAllRead_withError_shouldReturnError() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize)
        let store = createNotificationStore(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage),
            actionStoreExpectedResult: .failure(MagicBellError("Error"))
        )

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        let expectationMarkAllRead = XCTestExpectation(description: "MarkAllRead")
        var expectedError: Error?
        store.markAllRead { result in
            switch result {
            case .none:
                break
            case .some(let error):
                expectedError = error
            }
            expectationMarkAllRead.fulfill()
        }
        wait(for: [expectationMarkAllRead], timeout: 1)

        // THEN
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(1))
        expect(self.actionNotificationInteractor.executeCounter).to(equal(1))
        expect(self.actionNotificationInteractor.executeParamsSpy[0].notificationId).to(beNil())
        expect(self.actionNotificationInteractor.executeParamsSpy[0].action).to(equal(.markAllAsRead))
        expect(expectedError).toNot(beNil())
    }


    func test_markAllNotificationAsRead_withDefaultStorePredicate_shouldMarkAllNotificationWithReadDate() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize)
        let store = createNotificationStore(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        let initialCounts = InitialNotificationStoreCounts(store)
        let expectationMarkAllRead = XCTestExpectation(description: "MarkAllRead")
        store.markAllRead { _ in  expectationMarkAllRead.fulfill()}
        wait(for: [expectationMarkAllRead], timeout: 1)

        // THEN
        store.forEach {
            expect($0.readAt).toNot(beNil())
            expect($0.seenAt).toNot(beNil())
        }
        expect(store.totalCount).to(equal(initialCounts.totalCount))
        expect(store.unreadCount).to(equal(0))
        expect(store.unseenCount).to(equal(0))
    }

    func test_markAllNotificationAsRead_withUnreadStorePredicate_shouldClearNotifications() {
        // GIVEN
        let predicate = StorePredicate(read: .unread)
        let storePage = StorePage.create(
            edges: anyNotificationEdgeArray(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .unread),
            pageInfo: anyPageInfo()
        )
        let store = createNotificationStore(predicate: predicate, fetchStoreExpectedResult: .success(storePage))

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        let initialCounts = InitialNotificationStoreCounts(store)
        let expectationMarkAllRead = XCTestExpectation(description: "MarkAllRead")
        store.markAllRead { _ in  expectationMarkAllRead.fulfill()}
        wait(for: [expectationMarkAllRead], timeout: 1)

        // THEN
        store.forEach {
            expect($0.readAt).toNot(beNil())
            expect($0.seenAt).toNot(beNil())
        }
        expect(store.totalCount).toNot(equal(initialCounts.totalCount))
        expect(store.unreadCount).toNot(equal(initialCounts.unreadCount))
        expect(store.unseenCount).toNot(equal(initialCounts.unseenCount))
    }

    func test_markAllNotificationAsRead_withReadStorePredicate_shouldBeAllTheSame() {
        // GIVEN
        let predicate = StorePredicate(read: .read)
        let storePage = StorePage.create(
            edges: anyNotificationEdgeArray(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .read),
            pageInfo: anyPageInfo()
        )
        let store = createNotificationStore(predicate: predicate, fetchStoreExpectedResult: .success(storePage))

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        let initialCounts = InitialNotificationStoreCounts(store)
        let expectationMarkAllRead = XCTestExpectation(description: "MarkAllRead")
        store.markAllRead { _ in  expectationMarkAllRead.fulfill()}
        wait(for: [expectationMarkAllRead], timeout: 1)

        // THEN
        store.forEach {
            expect($0.readAt).toNot(beNil())
            expect($0.seenAt).toNot(beNil())
        }
        expect(store.totalCount).to(equal(initialCounts.totalCount))
        expect(store.unreadCount).to(equal(initialCounts.unreadCount))
        expect(store.unseenCount).to(equal(initialCounts.unseenCount))
    }

    func test_markAllNotificationSeen_withDefaultStorePredicate_shouldCallActioNotificationInteractor() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize)
        let store = createNotificationStore(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        let expectationMarkAllSeen = XCTestExpectation(description: "MarkAllSeen")
        store.markAllSeen { _ in  expectationMarkAllSeen.fulfill()}
        wait(for: [expectationMarkAllSeen], timeout: 1)

        // THEN
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(1))
        expect(self.actionNotificationInteractor.executeCounter).to(equal(1))
        expect(self.actionNotificationInteractor.executeParamsSpy[0].notificationId).to(beNil())
        expect(self.actionNotificationInteractor.executeParamsSpy[0].action).to(equal(.markAllAsSeen))
    }

    func test_markAllNotificationAsSeen_withDefaultStorePredicate_shouldMarkAllNotificationWithSeenDate() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize)
        let store = createNotificationStore(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        let initialCounts = InitialNotificationStoreCounts(store)
        let expectationMarkAllSeen = XCTestExpectation(description: "MarkAllSeen")
        store.markAllSeen { _ in  expectationMarkAllSeen.fulfill()}
        wait(for: [expectationMarkAllSeen], timeout: 1)

        // THEN
        store.forEach {
            expect($0.seenAt).toNot(beNil())
        }
        expect(store.totalCount).to(equal(initialCounts.totalCount))
        expect(store.unreadCount).to(equal(initialCounts.unreadCount))
        expect(store.unseenCount).to(equal(0))
    }

    func test_markAllNotificationAsSeen_withUnreadStorePredicate_shouldMarkAllNotificationWithSeenDate() {
        // GIVEN
        let predicate = StorePredicate(read: .unread)
        let storePage = StorePage.create(
            edges: anyNotificationEdgeArray(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .unread),
            pageInfo: anyPageInfo()
        )
        let store = createNotificationStore(predicate: predicate, fetchStoreExpectedResult: .success(storePage))

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        let initialCounts = InitialNotificationStoreCounts(store)
        let expectationMarkAllSeen = XCTestExpectation(description: "MarkAllSeen")
        store.markAllSeen { _ in  expectationMarkAllSeen.fulfill()}
        wait(for: [expectationMarkAllSeen], timeout: 1)

        // THEN
        expect(store.totalCount).to(equal(initialCounts.totalCount))
        expect(store.unreadCount).to(equal(initialCounts.unreadCount))
        expect(store.unseenCount).toNot(equal(initialCounts.unseenCount))
    }

    func test_markAllNotificationAsSeen_withReadStorePredicate_shouldMarkAllNotificationWithSeenDate() {
        // GIVEN
        let predicate = StorePredicate(read: .read)
        let storePage = StorePage.create(
            edges: anyNotificationEdgeArray(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .read),
            pageInfo: anyPageInfo()
        )
        let store = createNotificationStore(predicate: predicate, fetchStoreExpectedResult: .success(storePage))

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        let initialCounts = InitialNotificationStoreCounts(store)
        let expectationMarkAllSeen = XCTestExpectation(description: "MarkAllSeen")
        store.markAllSeen { _ in  expectationMarkAllSeen.fulfill()}
        wait(for: [expectationMarkAllSeen], timeout: 1)

        // THEN
        expect(store.totalCount).to(equal(initialCounts.totalCount))
        expect(store.unreadCount).to(equal(initialCounts.unreadCount))
        expect(store.unseenCount).to(equal(initialCounts.unseenCount))
    }

    func test_notifyInsertNotifications_withDefaultStorePredicate_ShouldNotifyInsertIndexesArray() {
        // GIVEN
        let contentObserver = ContentObserverMock()
        let predicate = StorePredicate()
        let storePage = StorePage.create(
            edges: anyNotificationEdgeArray(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .none),
            pageInfo: PageInfo.create(endCursor: AnyCursor.any.rawValue, hasNextPage: true)
        )
        let store = createNotificationStore(predicate: predicate, fetchStoreExpectedResult: .success(storePage))
        store.addContentObserver(contentObserver)

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotifications")
        store.fetch { _ in  expectation.fulfill() }
        wait(for: [expectation], timeout: 1)

        // THEN
        var indexes = Array(0..<storePage.edges.count)
        expect(contentObserver.didInsertCounter).to(equal(1))
        expect(contentObserver.didInsertSpy[0].indexes).to(equal(indexes))
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(1))
        expect(store.count).to(equal(defaultEdgeArraySize))

        let expectationPage = XCTestExpectation(description: "FetchNotification2")
        store.fetch { _ in expectationPage.fulfill() }
        wait(for: [expectationPage], timeout: 1)
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(2))
        expect(store.count).to(equal(defaultEdgeArraySize * self.fetchStorePageInteractor.executeCounter))
        indexes = Array(indexes.count..<store.count)
        expect(contentObserver.didInsertCounter).to(equal(2))
        expect(contentObserver.didInsertSpy[1].indexes).to(equal(indexes))
    }

    func test_notifyDeleteNotification_WithDefaultStorePredicate_ShouldNotifyCounters() {
        // GIVEN
        let contentObserver = ContentObserverMock()
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize)
        let store = createNotificationStore(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )
        store.addContentObserver(contentObserver)

        // WHEN
        let expectation = XCTestExpectation(description: "FetchNotifications")
        store.fetch { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
        let removeIndex = anyIndexForDefaultEdgeArraySize
        let expectationDelete = XCTestExpectation(description: "DeleteNotifications")
        store.delete(store[removeIndex]) { _ in  expectationDelete.fulfill()}
        wait(for: [expectationDelete], timeout: 1)

        // THEN
        expect(contentObserver.didDeleteCounter).to(equal(1))
        expect(contentObserver.didDeleteSpy[0].indexes).to(equal([removeIndex]))
    }
}
