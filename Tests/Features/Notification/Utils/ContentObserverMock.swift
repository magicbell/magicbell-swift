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

class ContentObserverMock: NotificationStoreContentObserver {

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
