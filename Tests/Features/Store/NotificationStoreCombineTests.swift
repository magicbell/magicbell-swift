//
//  NotificationStoreCombineTests.swift
//  MagicBell
//
//  Created by Javi on 27/12/21.
//

@testable import MagicBell
@testable import Harmony
import struct MagicBell.Notification
import XCTest
import Nimble
import Combine

class NotificationStoreCombineTests: XCTestCase {

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

    func test_deleteNotificationFuture_withDefaultStorePredicate_shouldCallDeleteNotificationInteractor() {
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
        _ = store.delete(store[removeIndex]).sink(receiveCompletion: { _ in expectationDelete.fulfill() }, receiveValue: {  })
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
        _ = store.delete(store[removeIndex]).sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                errorExpected = error
                expectationDelete.fulfill()
            case .finished:
                expectationDelete.fulfill()
            }
        }, receiveValue: {  })
        wait(for: [expectationDelete], timeout: 1)

        // THEN
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(1))
        expect(self.deleteNotificationInteractor.executeCounter).to(equal(1))
        expect(self.deleteNotificationInteractor.executeParamsSpy[0].notificationId).to(equal(removedNotification.id))
        expect(errorExpected).toNot(beNil())
    }

    func test_markNotificationAsReadFuture_withDefaultStorePredicate_shouldCallActioNotificationInteractor() {
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
        _ = store.markAsRead(store[chosenIndex]).sink { _ in expectationMarkAsRead.fulfill() } receiveValue: { _ in }
        wait(for: [expectationMarkAsRead], timeout: 1)

        // THEN
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(1))
        expect(self.actionNotificationInteractor.executeCounter).to(equal(1))
        expect(self.actionNotificationInteractor.executeParamsSpy[0].notificationId).to(equal(markReadNotification.id))
        expect(self.actionNotificationInteractor.executeParamsSpy[0].action).to(equal(.markAsRead))
    }

    func test_markNotificationAsReadFuture_withError_shouldReturnError() {
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
        _ = store.markAsRead(store[chosenIndex]).sink { completion in
            switch completion {
            case .failure(let error):
                errorExpected = error
                expectationMarkAsRead.fulfill()
            case .finished:
                expectationMarkAsRead.fulfill()
            }
        } receiveValue: { _ in }
        wait(for: [expectationMarkAsRead], timeout: 1)

        // THEN
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(1))
        expect(self.actionNotificationInteractor.executeCounter).to(equal(1))
        expect(self.actionNotificationInteractor.executeParamsSpy[0].notificationId).to(equal(markReadNotification.id))
        expect(self.actionNotificationInteractor.executeParamsSpy[0].action).to(equal(.markAsRead))
        expect(errorExpected).toNot(beNil())
    }

    func test_markNotificationAsUnreadFuture_withDefaultStorePredicate_shouldCallActioNotificationInteractor() {
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
        let expectationMarkAsUnread = XCTestExpectation(description: "MarkAsUnread")
        store.markAsUnread(store[chosenIndex]) { _ in  expectationMarkAsUnread.fulfill()}
        wait(for: [expectationMarkAsUnread], timeout: 1)

        // THEN
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(1))
        expect(self.actionNotificationInteractor.executeCounter).to(equal(1))
        expect(self.actionNotificationInteractor.executeParamsSpy[0].notificationId).to(equal(markUnreadNotification.id))
        expect(self.actionNotificationInteractor.executeParamsSpy[0].action).to(equal(.markAsUnread))
    }

    func test_markNotificationAsArchiveFuture_withDefaultStorePredicate_shouldCallActioNotificationInteractor() {
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
        _ = store.archive(store[chosenIndex]).sink(receiveCompletion: { _ in expectationArchive.fulfill() }, receiveValue: {  })
        wait(for: [expectationArchive], timeout: 1)

        // THEN
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(1))
        expect(self.actionNotificationInteractor.executeCounter).to(equal(1))
        expect(self.actionNotificationInteractor.executeParamsSpy[0].notificationId).to(equal(archiveNotification.id))
        expect(self.actionNotificationInteractor.executeParamsSpy[0].action).to(equal(.archive))
    }

    func test_markNotificationAsUnarchiveFuture_withDefaultStorePredicate_shouldCallActionNotificationInteractor() {
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
        _ = store.unarchive(store[chosenIndex]).sink(receiveCompletion: { _ in expectationArchive.fulfill() }, receiveValue: {  })
        wait(for: [expectationArchive], timeout: 1)

        // THEN
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(1))
        expect(self.actionNotificationInteractor.executeCounter).to(equal(1))
        expect(self.actionNotificationInteractor.executeParamsSpy[0].notificationId).to(equal(unarchiveNotification.id))
        expect(self.actionNotificationInteractor.executeParamsSpy[0].action).to(equal(.unarchive))
    }

    func test_markNotificationAllReadFuture_withDefaultStorePredicate_shouldCallActioNotificationInteractor() {
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
        _ = store.markAllRead().sink(receiveCompletion: { _ in expectationMarkAllRead.fulfill() }, receiveValue: {  })
        wait(for: [expectationMarkAllRead], timeout: 1)

        // THEN
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(1))
        expect(self.actionNotificationInteractor.executeCounter).to(equal(1))
        expect(self.actionNotificationInteractor.executeParamsSpy[0].notificationId).to(beNil())
        expect(self.actionNotificationInteractor.executeParamsSpy[0].action).to(equal(.markAllAsRead))
    }

    func test_markAllNotificationSeenFuture_withDefaultStorePredicate_shouldCallActioNotificationInteractor() {
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
        _ = store.markAllSeen().sink(receiveCompletion: { _ in expectationMarkAllSeen.fulfill() }, receiveValue: {  })
        wait(for: [expectationMarkAllSeen], timeout: 1)

        // THEN
        expect(self.fetchStorePageInteractor.executeCounter).to(equal(1))
        expect(self.actionNotificationInteractor.executeCounter).to(equal(1))
        expect(self.actionNotificationInteractor.executeParamsSpy[0].notificationId).to(beNil())
        expect(self.actionNotificationInteractor.executeParamsSpy[0].action).to(equal(.markAllAsSeen))
    }
}
