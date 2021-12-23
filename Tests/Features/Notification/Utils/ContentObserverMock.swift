//
//  ContentObserverMock.swift
//  MagicBellTests
//
//  Created by Javi on 21/12/21.
//

@testable import MagicBell

class ContentObserverMock: NotificationStoreContentDelegate {

    private(set) var reloadStoreSpy:[MethodParams.ReloadStore] = []
    var reloadStoreCounter: Int {
        reloadStoreSpy.count
    }
    private(set) var didInsertSpy:[MethodParams.DidInsert] = []
    var didInsertCounter: Int {
        didInsertSpy.count
    }
    private(set) var didChangeSpy:[MethodParams.DidChange] = []
    var didChangeCounter: Int {
        didChangeSpy.count
    }
    private(set) var didDeleteSpy:[MethodParams.DidDelete] = []
    var didDeleteCounter: Int {
        didDeleteSpy.count
    }

    func didReloadStore(_ store: NotificationStore) {
        reloadStoreSpy.append(MethodParams.ReloadStore())
    }

    func store(_ store: NotificationStore, didInsertNotificationsAt indexes: [Int]) {
        didInsertSpy.append(MethodParams.DidInsert(indexes: indexes))
    }

    func store(_ store: NotificationStore, didChangeNotificationAt indexes: [Int]) {
        didChangeSpy.append(MethodParams.DidChange(indexes: indexes))
    }

    func store(_ store: NotificationStore, didDeleteNotificationAt indexes: [Int]) {
        didDeleteSpy.append(MethodParams.DidDelete(indexes: indexes))
    }

    class MethodParams {

        struct ReloadStore {

        }

        struct DidInsert {
            let indexes: [Int]
        }

        struct DidChange {
            let indexes: [Int]
        }

        struct DidDelete {
            let indexes: [Int]
        }
    }
}
