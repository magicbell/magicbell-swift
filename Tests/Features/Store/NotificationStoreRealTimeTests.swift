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
import Harmony
import struct MagicBell.Notification
import XCTest
import Nimble

class NotificationStoreRealTimeTests: XCTestCase {
    let defaultEdgeArraySize = 50
    lazy var anyIndexForDefaultEdgeArraySize = Int.random(in: 0..<defaultEdgeArraySize)
    let userQuery = UserQuery(email: "javier@mobilejazz.com")

    var storeRealTime: StoreRealTimeMock!
    var fetchStorePageInteractor: FetchStorePageMockInteractor!
    var actionNotificationInteractor: ActionNotificationMockInteractor!
    var deleteNotificationInteractor: DeleteNotificationMockInteractor!
    var getConfigInteractor: GetConfigMockInteractor!
    var deleteConfigInteractor: DeleteConfigMockInteractor!

    var storeDirector: StoreDirector!

    private func createStoreDirector(predicate: StorePredicate, fetchStoreExpectedResult: Result<StorePage, Error>) -> NotificationStore {
        fetchStorePageInteractor = FetchStorePageMockInteractor(expectedResult: fetchStoreExpectedResult)
        actionNotificationInteractor = ActionNotificationMockInteractor(expectedResult: .success(()))
        deleteNotificationInteractor = DeleteNotificationMockInteractor(expectedResult: .success(()))
        getConfigInteractor = GetConfigMockInteractor(expectedResult: .success(Config(channel: "channel-1")))
        deleteConfigInteractor = DeleteConfigMockInteractor(expectedResult: .success(()))
        storeRealTime = StoreRealTimeMock()
        storeDirector = RealTimeByPredicateStoreDirector(
            logger: DeviceConsoleLogger(),
            userQuery: userQuery,
            fetchStorePageInteractor: fetchStorePageInteractor,
            actionNotificationInteractor: actionNotificationInteractor,
            deleteNotificationInteractor: deleteNotificationInteractor,
            getConfigInteractor: getConfigInteractor,
            deleteConfigInteractor: deleteConfigInteractor,
            storeRealTime: storeRealTime)

        return storeDirector.build(predicate: predicate)
    }

    func test_addRealTimeStore() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize)

        // WHEN
        _ = createStoreDirector(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // THEN
        expect(self.storeRealTime.observers.count).to(equal(1))
    }

    func test_notifyNewNotification_withDefaultStorePredicate_shouldRefreshStore() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize)
        let store = createStoreDirector(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        let expectation = expectation(description: "FetchNotifications")
        store.fetch { _ in expectation.fulfill() }
        waitForExpectations(timeout: 1, handler: nil)
        storeRealTime.processMessage(event: .newNotification(id: "NewNotification"))

        // THEN
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(2))
        expect(store.count).to(equal(defaultEdgeArraySize))
        storePage.edges.enumerated().forEach { idx, edge in
            expect(store[idx].id).to(equal(edge.node.id))
        }
    }

    func test_notifyReadNotification_withDefaultStorePredicateAndReadAndExists_shouldDoNothing() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .read)
        let store = createStoreDirector(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        let expectation = expectation(description: "FetchNotifications")
        store.fetch { _ in expectation.fulfill() }
        waitForExpectations(timeout: 1, handler: nil)
        let initialCounter = InitialNotificationStoreCounts(store)
        let chosenIndex = anyIndexForDefaultEdgeArraySize
        storeRealTime.processMessage(event: .readNotification(id: String(chosenIndex)))

        // THEN
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(1))
        expect(store.count).to(equal(defaultEdgeArraySize))
        expect(store.totalCount).to(equal(initialCounter.totalCount))
        expect(store.unreadCount).to(equal(initialCounter.unreadCount))
    }

    func test_notifyReadNotification_withDefaultStorePredicateAndUnreadAndExists_shouldUpdateNotification() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .unread)
        let store = createStoreDirector(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        let expectation = expectation(description: "FetchNotifications")
        store.fetch { _ in expectation.fulfill() }
        waitForExpectations(timeout: 1, handler: nil)
        let initialCounter = InitialNotificationStoreCounts(store)
        let chosenIndex = anyIndexForDefaultEdgeArraySize
        storeRealTime.processMessage(event: .readNotification(id: String(chosenIndex)))

        // THEN
        expect(store[chosenIndex].readAt).toNot(beNil())
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(1))
        expect(store.count).to(equal(defaultEdgeArraySize))
        expect(store.totalCount).to(equal(initialCounter.totalCount))
        expect(store.unreadCount).to(equal(initialCounter.unreadCount - 1))
    }

    func test_notifyReadNotification_withDefaultStorePredicateAndUnseenAndExists_shouldUpdateNotification() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .unseen)
        let store = createStoreDirector(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        let expectation = expectation(description: "FetchNotifications")
        store.fetch { _ in expectation.fulfill() }
        waitForExpectations(timeout: 1, handler: nil)
        let initialCounter = InitialNotificationStoreCounts(store)
        let chosenIndex = anyIndexForDefaultEdgeArraySize
        storeRealTime.processMessage(event: .readNotification(id: String(chosenIndex)))

        // THEN
        expect(store[chosenIndex].readAt).toNot(beNil())
        expect(store[chosenIndex].seenAt).toNot(beNil())
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(1))
        expect(store.count).to(equal(defaultEdgeArraySize))
        expect(store.totalCount).to(equal(initialCounter.totalCount))
        expect(store.unreadCount).to(equal(initialCounter.unreadCount - 1))
        expect(store.unseenCount).to(equal(initialCounter.unseenCount - 1))
    }

    func test_notifyReadNotification_withDefaultStorePredicateAndDoesntExists_shouldRefresh() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize)
        let store = createStoreDirector(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        let expectation = expectation(description: "FetchNotifications")
        store.fetch { _ in expectation.fulfill() }
        waitForExpectations(timeout: 1, handler: nil)
        storeRealTime.processMessage(event: .readNotification(id: String("not exists")))

        // THEN
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(2))
        expect(store.count).to(equal(defaultEdgeArraySize))
        storePage.edges.enumerated().forEach { idx, edge in
            expect(store[idx].id).to(equal(edge.node.id))
        }
    }

    func test_notifyUnreadNotification_withDefaultStorePredicateAndReadAndExists_shouldUpdateNotification() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .read)
        let store = createStoreDirector(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        let expectation = expectation(description: "FetchNotifications")
        store.fetch { _ in expectation.fulfill() }
        waitForExpectations(timeout: 1, handler: nil)
        let initialCounter = InitialNotificationStoreCounts(store)
        let chosenIndex = anyIndexForDefaultEdgeArraySize
        storeRealTime.processMessage(event: .unreadNotification(id: String(chosenIndex)))

        // THEN
        expect(store.unseenCount).to(equal(initialCounter.unseenCount))
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(1))
        expect(store.count).to(equal(defaultEdgeArraySize))
        expect(store[chosenIndex].readAt).to(beNil())
        expect(store.unreadCount).to(equal(initialCounter.unreadCount + 1))
        expect(store.totalCount).to(equal(initialCounter.totalCount))
    }

    func test_notifyUnreadNotification_withDefaultStorePredicateAndUnreadAndExists_shouldUpdateNotification() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .unread)
        let store = createStoreDirector(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        let expectation = expectation(description: "FetchNotifications")
        store.fetch { _ in expectation.fulfill() }
        waitForExpectations(timeout: 1, handler: nil)
        let initialCounter = InitialNotificationStoreCounts(store)
        let chosenIndex = anyIndexForDefaultEdgeArraySize
        storeRealTime.processMessage(event: .unreadNotification(id: String(chosenIndex)))

        // THEN
        expect(store.unseenCount).to(equal(initialCounter.unseenCount))
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(1))
        expect(store.count).to(equal(defaultEdgeArraySize))
        expect(store[chosenIndex].readAt).to(beNil())
        expect(store.unreadCount).to(equal(initialCounter.unreadCount))
        expect(store.totalCount).to(equal(initialCounter.totalCount))
    }

    func test_notifyUnreadNotification_withDefaultStorePredicateAndNotExists_shouldRefresh() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize)
        let store = createStoreDirector(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        let expectation = expectation(description: "FetchNotifications")
        store.fetch { _ in expectation.fulfill() }
        waitForExpectations(timeout: 1, handler: nil)
        storeRealTime.processMessage(event: .unreadNotification(id: String("not exists")))

        // THEN
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(2))
        expect(store.count).to(equal(defaultEdgeArraySize))
    }

    func test_notifyDeleteNotification_withDefaultStorePredicateAndUnreadAndExists_shouldRemoveNotificationAndUnreadCount() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .unread)
        let store = createStoreDirector(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        let expectation = expectation(description: "FetchNotifications")
        store.fetch { _ in expectation.fulfill() }
        waitForExpectations(timeout: 1, handler: nil)
        let initialCounter = InitialNotificationStoreCounts(store)
        let chosenIndex = anyIndexForDefaultEdgeArraySize
        let removedNotificationId = store[chosenIndex].id
        storeRealTime.processMessage(event: .deleteNotification(id: String(chosenIndex)))

        // THEN
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(1))
        expect(store.totalCount).to(equal(initialCounter.totalCount - 1))
        expect(store.unreadCount).to(equal(initialCounter.unreadCount - 1))
        store.forEach { notification in
            expect(notification.id).toNot(equal(removedNotificationId))
        }
    }

    func test_notifyDeleteNotification_withDefaultStorePredicateAndUnseenAndExists_shouldUpdateUnseenCount() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .unseen)
        let store = createStoreDirector(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        let expectation = expectation(description: "FetchNotifications")
        store.fetch { _ in expectation.fulfill() }
        waitForExpectations(timeout: 1, handler: nil)
        let initialCounter = InitialNotificationStoreCounts(store)
        let chosenIndex = anyIndexForDefaultEdgeArraySize
        storeRealTime.processMessage(event: .deleteNotification(id: String(chosenIndex)))

        // THEN
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(1))
        expect(store.unseenCount).to(equal(initialCounter.unseenCount - 1))
    }

    func test_notifyDeleteNotification_withDefaultStorePredicateAndSeenAndExists_shouldSameUnseenCount() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .seen)
        let store = createStoreDirector(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        let expectation = expectation(description: "FetchNotifications")
        store.fetch { _ in expectation.fulfill() }
        waitForExpectations(timeout: 1, handler: nil)
        let initialCounter = InitialNotificationStoreCounts(store)
        let chosenIndex = anyIndexForDefaultEdgeArraySize
        storeRealTime.processMessage(event: .deleteNotification(id: String(chosenIndex)))

        // THEN
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(1))
        expect(store.unseenCount).to(equal(initialCounter.unseenCount))
    }

    func test_notifyDeleteNotification_withDefaultStorePredicateAndNotExists_shouldDoNothing() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize)
        let store = createStoreDirector(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        let expectation = expectation(description: "FetchNotifications")
        store.fetch { _ in expectation.fulfill() }
        waitForExpectations(timeout: 1, handler: nil)
        let initialCounter = InitialNotificationStoreCounts(store)
        storeRealTime.processMessage(event: .deleteNotification(id: String("not exists")))

        // THEN
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(1))
        expect(store.totalCount).to(equal(initialCounter.totalCount))
        expect(store.unreadCount).to(equal(initialCounter.unreadCount))
        expect(store.unseenCount).to(equal(initialCounter.unseenCount))
    }

    func test_notifyReadAllNotification_withDefaultStorePredicate_shouldRefresh() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .read)
        let store = createStoreDirector(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        let expectation = expectation(description: "FetchNotifications")
        store.fetch { _ in expectation.fulfill() }
        waitForExpectations(timeout: 1, handler: nil)
        storeRealTime.processMessage(event: .readAllNotification)

        // THEN
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(2))
        expect(store.count).to(equal(defaultEdgeArraySize))
        store.forEach { notification in
            expect(notification.readAt).toNot(beNil())
        }
    }

    func test_notifySeenAllNotification_withDefaultStorePredicate_shouldRefresh() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .read)
        let store = createStoreDirector(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        let expectation = expectation(description: "FetchNotifications")
        store.fetch { _ in expectation.fulfill() }
        waitForExpectations(timeout: 1, handler: nil)
        storeRealTime.processMessage(event: .seenAllNotification)

        // THEN
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(2))
        expect(store.count).to(equal(defaultEdgeArraySize))
        store.forEach { notification in
            expect(notification.seenAt).toNot(beNil())
        }
    }

    // MARK: - Observer tests

    func test_addContentObserver_ShouldNotifyRefreshStore() {
        // GIVEN
        let contentObserver = ContentObserverMock()
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize)
        let store = createStoreDirector(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )
        store.addContentObserver(contentObserver)

        // WHEN
        storeRealTime.processMessage(event: .newNotification(id: "NewNotification"))

        // THEN
        expect(contentObserver.reloadStoreCounter).to(equal(1))
        expect(contentObserver.reloadStoreSpy).toNot(beEmpty())
    }

    func test_notifyReadNotification_withReadStorePredicateAndExists_ShouldDidChangeDelegate() {
        // GIVEN
        let contentObserver = ContentObserverMock()
        let predicate = StorePredicate(read: true)
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .read)
        let store = createStoreDirector(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )
        store.addContentObserver(contentObserver)

        // WHEN
        let expectation = expectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill()}
        waitForExpectations(timeout: 1, handler: nil)
        let chosenIndex = anyIndexForDefaultEdgeArraySize
        storeRealTime.processMessage(event: .readNotification(id: String(chosenIndex)))

        // THEN
        expect(contentObserver.reloadStoreCounter).to(equal(0))
        expect(contentObserver.didChangeCounter).to(equal(1))
        expect(contentObserver.didChangeSpy[0].indexes).to(equal([chosenIndex]))
    }

    func test_notifyReadNotification_withReadStorePredicateAndDoesntExist_ShouldNotifyReadNotification() {
        // GIVEN
        let contentObserver = ContentObserverMock()
        let predicate = StorePredicate(read: true)
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .read)
        let store = createStoreDirector(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )
        store.addContentObserver(contentObserver)

        // WHEN
        let expectation = expectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill()}
        waitForExpectations(timeout: 1, handler: nil)
        storeRealTime.processMessage(event: .readNotification(id: String("not exists")))

        // THEN
        expect(contentObserver.reloadStoreCounter).to(equal(1))
        expect(contentObserver.didChangeCounter).to(equal(0))
    }

    func test_notifyReadNotification_WithUnreadStorePredicateAndExists_ShouldNotifyChange() {
        // GIVEN
        let contentObserver = ContentObserverMock()
        let predicate = StorePredicate(read: false)
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .unread)
        let store = createStoreDirector(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )
        store.addContentObserver(contentObserver)

        // WHEN
        let expectation = expectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill()}
        waitForExpectations(timeout: 1, handler: nil)
        let chosenIndex = anyIndexForDefaultEdgeArraySize
        storeRealTime.processMessage(event: .readNotification(id: String(chosenIndex)))


        // THEN
        expect(contentObserver.reloadStoreCounter).to(equal(0))
        expect(contentObserver.didChangeCounter).to(equal(0))
        expect(contentObserver.didDeleteCounter).to(equal(1))
        expect(contentObserver.didDeleteSpy[0].indexes).to(equal([chosenIndex]))
    }

    func test_notifyDeleteNotification_WithDefaultStorePredicateAndExists_ShouldNotifyDeletion() {
        // GIVEN
        let contentObserver = ContentObserverMock()
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize)
        let store = createStoreDirector(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )
        store.addContentObserver(contentObserver)

        // WHEN
        let expectation = expectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill()}
        waitForExpectations(timeout: 1, handler: nil)
        let chosenIndex = anyIndexForDefaultEdgeArraySize
        storeRealTime.processMessage(event: .deleteNotification(id: String(chosenIndex)))

        // THEN
        expect(contentObserver.reloadStoreCounter).to(equal(0))
        expect(contentObserver.didChangeCounter).to(equal(0))
        expect(contentObserver.didDeleteCounter).to(equal(1))
        expect(contentObserver.didDeleteSpy[0].indexes).to(equal([chosenIndex]))
    }

    func test_notifyMarkAllRead_WithUnreadStorePredicate_ShouldClearStore() {
        // GIVEN
        let contentObserver = ContentObserverMock()
        let predicate = StorePredicate(read: false)
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .unread)
        let store = createStoreDirector(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )
        store.addContentObserver(contentObserver)

        // WHEN
        let expectation = expectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill()}
        let initialCounts = InitialNotificationStoreCounts(store)
        waitForExpectations(timeout: 1, handler: nil)
        storeRealTime.processMessage(event: .readAllNotification)

        // THEN
        expect(contentObserver.reloadStoreCounter).to(equal(0))
        expect(contentObserver.didChangeCounter).to(equal(0))
        expect(contentObserver.didDeleteCounter).to(equal(1))
        expect(contentObserver.didDeleteSpy[0].indexes).to(equal(Array(0..<initialCounts.totalCount)))
        expect(store.totalCount).to(equal(0))
        expect(store.unreadCount).to(equal(0))
        expect(store.unseenCount).to(equal(0))
    }

    func test_notifyMarkAllSeen_WithUnseenStorePredicate_ShouldClearStore() {
        // GIVEN
        let contentObserver = ContentObserverMock()
        let predicate = StorePredicate(seen: false)
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .unseen)
        let store = createStoreDirector(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )
        store.addContentObserver(contentObserver)

        // WHEN
        let expectation = expectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill()}
        let initialCounts = InitialNotificationStoreCounts(store)
        waitForExpectations(timeout: 1, handler: nil)
        storeRealTime.processMessage(event: .seenAllNotification)

        // THEN
        expect(contentObserver.reloadStoreCounter).to(equal(0))
        expect(contentObserver.didChangeCounter).to(equal(0))
        expect(contentObserver.didDeleteCounter).to(equal(1))
        expect(contentObserver.didDeleteSpy[0].indexes).to(equal(Array(0..<initialCounts.totalCount)))
        expect(store.totalCount).to(equal(0))
        expect(store.unreadCount).to(equal(0))
        expect(store.unseenCount).to(equal(0))
    }

    func test_notifyNewNotification_WithDefaultStorePredicate_ShouldRefreshStoreAndCounters() {
        // GIVEN
        let countObserver = CountObserverMock()
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize)
        let store = createStoreDirector(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )
        store.addCountObserver(countObserver)

        // WHEN
        let expectation = expectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill()}
        waitForExpectations(timeout: 1, handler: nil)
        storeRealTime.processMessage(event: .newNotification(id: "NewId"))

        // THEN
        expect(countObserver.totalCountCounter).to(equal(2))
        expect(countObserver.unreadCountCounter).to(equal(2))
        expect(countObserver.unseenCountCounter).to(equal(2))
    }

    func test_notifyReadNotification_WithDefaultStorePredicateAndUnread_ShouldRefreshStoreAndCounters() {
        // GIVEN
        let countObserver = CountObserverMock()
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .unread)
        let store = createStoreDirector(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )
        store.addCountObserver(countObserver)

        // WHEN
        let expectation = expectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill()}
        let initialCounts = InitialNotificationStoreCounts(store)
        waitForExpectations(timeout: 1, handler: nil)
        let chosenIndex = anyIndexForDefaultEdgeArraySize
        storeRealTime.processMessage(event: .readNotification(id: String(chosenIndex)))

        // THEN
        expect(countObserver.totalCountCounter).to(equal(1))
        expect(countObserver.totalCountSpy[0].count).to(equal(store.count))
        expect(countObserver.unreadCountCounter).to(equal(2))
        expect(countObserver.unreadCountSpy[0].count).to(equal(initialCounts.unreadCount))
        expect(countObserver.unreadCountSpy[1].count).to(equal(initialCounts.unreadCount - 1))
    }

    func test_notifyReadNotification_WithDefaultStorePredicateAndRead_ShouldRefreshStoreAndCounters() {
        // GIVEN
        let countObserver = CountObserverMock()
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .read)
        let store = createStoreDirector(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )
        store.addCountObserver(countObserver)

        // WHEN
        let expectation = expectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill()}
        waitForExpectations(timeout: 1, handler: nil)
        let chosenIndex = anyIndexForDefaultEdgeArraySize
        storeRealTime.processMessage(event: .readNotification(id: String(chosenIndex)))

        // THEN
        expect(countObserver.totalCountCounter).to(equal(1))
        expect(countObserver.totalCountSpy[0].count).to(equal(store.count))
        expect(countObserver.unreadCountCounter).to(equal(0))
    }

    func test_notifyReadNotification_WithDefaultStorePredicateAndUnseen_ShouldRefreshStoreAndCounters() {
        // GIVEN
        let countObserver = CountObserverMock()
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .unseen)
        let store = createStoreDirector(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )
        store.addCountObserver(countObserver)

        // WHEN
        let expectation = expectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill()}
        let initialCounts = InitialNotificationStoreCounts(store)
        waitForExpectations(timeout: 1, handler: nil)
        let chosenIndex = anyIndexForDefaultEdgeArraySize
        storeRealTime.processMessage(event: .readNotification(id: String(chosenIndex)))

        // THEN
        expect(countObserver.totalCountCounter).to(equal(1))
        expect(countObserver.totalCountSpy[0].count).to(equal(store.count))
        expect(countObserver.unseenCountCounter).to(equal(2))
        expect(countObserver.unseenCountSpy[0].count).to(equal(initialCounts.unseenCount))
        expect(countObserver.unseenCountSpy[1].count).to(equal(initialCounts.unseenCount - 1))
    }

    func test_notifyReadNotification_WithDefaultStorePredicateAndSeen_ShouldRefreshStoreAndCounters() {
        // GIVEN
        let countObserver = CountObserverMock()
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .seen)
        let store = createStoreDirector(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )
        store.addCountObserver(countObserver)

        // WHEN
        let expectation = expectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill()}
        waitForExpectations(timeout: 1, handler: nil)
        let chosenIndex = anyIndexForDefaultEdgeArraySize
        storeRealTime.processMessage(event: .readNotification(id: String(chosenIndex)))

        // THEN
        expect(countObserver.totalCountCounter).to(equal(1))
        expect(countObserver.totalCountSpy[0].count).to(equal(store.count))
        expect(countObserver.unseenCountCounter).to(equal(0))
    }

    func test_notifyReadNotification_WithUnreadStorePredicateAndUnread_ShouldRefreshStoreAndCounters() {
        // GIVEN
        let countObserver = CountObserverMock()
        let predicate = StorePredicate(read: false)
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .unread)
        let store = createStoreDirector(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )
        store.addCountObserver(countObserver)

        // WHEN
        let expectation = expectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill()}
        let initialCounts = InitialNotificationStoreCounts(store)
        waitForExpectations(timeout: 1, handler: nil)
        let chosenIndex = anyIndexForDefaultEdgeArraySize
        storeRealTime.processMessage(event: .readNotification(id: String(chosenIndex)))

        expect(countObserver.totalCountCounter).to(equal(2))
        expect(countObserver.unreadCountCounter).to(equal(2))
        expect(countObserver.unreadCountSpy[0].count).to(equal(initialCounts.unreadCount))
        expect(countObserver.unreadCountSpy[1].count).to(equal(initialCounts.unreadCount - 1))
    }

    func test_notifyReadNotification_WithUnreadStorePredicateAndRead_ShouldRefreshStoreAndCounters() {
        // GIVEN
        let countObserver = CountObserverMock()
        let predicate = StorePredicate(read: false)
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .read)
        let store = createStoreDirector(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )
        store.addCountObserver(countObserver)

        // WHEN
        let expectation = expectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill()}
        waitForExpectations(timeout: 1, handler: nil)
        let chosenIndex = anyIndexForDefaultEdgeArraySize
        storeRealTime.processMessage(event: .readNotification(id: String(chosenIndex)))

        expect(countObserver.totalCountCounter).to(equal(1))
        expect(countObserver.unreadCountCounter).to(equal(0))
    }

    func test_notifyReadNotification_WithUnreadStorePredicateAndUnseen_ShouldRefreshStoreAndCounters() {
        // GIVEN
        let countObserver = CountObserverMock()
        let predicate = StorePredicate(read: false)
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .unseen)
        let store = createStoreDirector(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )
        store.addCountObserver(countObserver)

        // WHEN
        let expectation = expectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill()}
        waitForExpectations(timeout: 1, handler: nil)
        let initialCounts = InitialNotificationStoreCounts(store)
        let chosenIndex = anyIndexForDefaultEdgeArraySize
        storeRealTime.processMessage(event: .readNotification(id: String(chosenIndex)))

        // THEN
        expect(countObserver.totalCountCounter).to(equal(2))
        expect(countObserver.totalCountSpy[0].count).to(equal(initialCounts.totalCount))
        expect(countObserver.totalCountSpy[1].count).to(equal(initialCounts.totalCount - 1))
        expect(countObserver.unseenCountCounter).to(equal(2))
        expect(countObserver.unseenCountSpy[0].count).to(equal(initialCounts.unseenCount))
        expect(countObserver.unseenCountSpy[1].count).to(equal(initialCounts.unseenCount - 1))
    }

    func test_notifyReadNotification_WithUnreadStorePredicateAndSeen_ShouldRefreshStoreAndCounters() {
        // GIVEN
        let countObserver = CountObserverMock()
        let predicate = StorePredicate(read: false)
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .seen)
        let store = createStoreDirector(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )
        store.addCountObserver(countObserver)

        // WHEN
        let expectation = expectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill()}
        waitForExpectations(timeout: 1, handler: nil)
        let initialCounts = InitialNotificationStoreCounts(store)
        let chosenIndex = anyIndexForDefaultEdgeArraySize
        storeRealTime.processMessage(event: .readNotification(id: String(chosenIndex)))

        // THEN
        expect(countObserver.totalCountCounter).to(equal(2))
        expect(countObserver.totalCountSpy[0].count).to(equal(initialCounts.totalCount))
        expect(countObserver.totalCountSpy[1].count).to(equal(initialCounts.totalCount - 1))
        expect(countObserver.unseenCountCounter).to(equal(0))
    }

    func test_notifyReadAllNotification_WithDefaultStorePredicateAndRead_ShouldNotifyCounters() {
        // GIVEN
        let countObserver = CountObserverMock()
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .none)
        let store = createStoreDirector(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )
        store.addCountObserver(countObserver)

        // WHEN
        let expectation = expectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill()}
        waitForExpectations(timeout: 1, handler: nil)
        let initialCounts = InitialNotificationStoreCounts(store)
        fetchStorePageInteractor.expectedResult = Result.success(givenPageStore(predicate: predicate, size: 15, forceNotificationProperty: .read))
        storeRealTime.processMessage(event: .readAllNotification)

        // THEN
        expect(countObserver.totalCountCounter).to(equal(2))
        expect(countObserver.unreadCountCounter).to(equal(1))
        expect(countObserver.unreadCountSpy[0].count).to(equal(initialCounts.unreadCount))
        expect(countObserver.unseenCountCounter).to(equal(1))
    }

    func test_notifySeenAllNotification_WithDefaultStorePredicate_ShouldNotifyCounters() {
        // GIVEN
        let countObserver = CountObserverMock()
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .unread)
        let store = createStoreDirector(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )
        store.addCountObserver(countObserver)

        //WHEN
        let expectation = expectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill()}
        waitForExpectations(timeout: 1, handler: nil)
        let initialCounts = InitialNotificationStoreCounts(store)
        let secondPageStore = givenPageStore(predicate: predicate, size: 15, forceNotificationProperty: .read)
        fetchStorePageInteractor.expectedResult = Result.success(secondPageStore)
        storeRealTime.processMessage(event: .seenAllNotification)

        expect(countObserver.totalCountCounter).to(equal(2))
        expect(countObserver.unreadCountCounter).to(equal(1))
        expect(countObserver.unreadCountSpy[0].count).to(equal(initialCounts.unreadCount))
        expect(countObserver.unseenCountCounter).to(equal(1))
        expect(countObserver.unseenCountSpy[0].count).to(equal(initialCounts.unseenCount))
    }

    func test_removeCountObserver() {
        // GIVEN
        let countObserver = CountObserverMock()
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .unread)
        let store = createStoreDirector(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        store.addCountObserver(countObserver)
        store.removeCountObserver(countObserver)
        storeRealTime.processMessage(event: .seenAllNotification)
        let expectation = expectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill()}
        waitForExpectations(timeout: 1, handler: nil)

        // THEN
        expect(countObserver.totalCountCounter).to(equal(0))
    }

    func test_removeContentObserver() {
        // GIVEN
        let contentObserver = ContentObserverMock()
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .unread)
        let store = createStoreDirector(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        store.addContentObserver(contentObserver)
        store.removeContentObserver(contentObserver)
        let expectation = expectation(description: "FetchNotification")
        store.fetch { _ in expectation.fulfill()}
        waitForExpectations(timeout: 1, handler: nil)

        // THEN
        expect(contentObserver.didInsertCounter).to(equal(0))
    }

    func test_notifyArchiveNotification_withDefaultStorePredicateAndExists_shouldDoNothing() {
        // GIVEN
        let predicate = StorePredicate()
        let storePage = givenPageStore(predicate: predicate, size: defaultEdgeArraySize, forceNotificationProperty: .unarchived)
        let store = createStoreDirector(
            predicate: predicate,
            fetchStoreExpectedResult: .success(storePage)
        )

        // WHEN
        let expectation = expectation(description: "FetchNotifications")
        store.fetch { _ in expectation.fulfill() }
        waitForExpectations(timeout: 1, handler: nil)
        let initialCounter = InitialNotificationStoreCounts(store)
        let chosenIndex = anyIndexForDefaultEdgeArraySize
        storeRealTime.processMessage(event: .archiveNotification(id: String(chosenIndex)))

        // THEN
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(1))
        expect(store.count).to(equal(defaultEdgeArraySize - 1))
        expect(store.totalCount).to(equal(initialCounter.totalCount - 1))
    }
}
