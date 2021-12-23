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

class CountObserverMock: NotificationStoreCountObserver {

    private(set) var totalCountSpy:[MethodParams.TotalCount] = []
    var totalCountCounter: Int {
        totalCountSpy.count
    }
    private(set) var unreadCountSpy:[MethodParams.UnreadCount] = []
    var unreadCountCounter: Int {
        unreadCountSpy.count
    }
    private(set) var unseenCountSpy:[MethodParams.UnseenCount] = []
    var unseenCountCounter: Int {
        unseenCountSpy.count
    }

    func store(_ store: NotificationStore, didChangeTotalCount count: Int) {
        totalCountSpy.append(MethodParams.TotalCount(count: count))
    }

    func store(_ store: NotificationStore, didChangeUnreadCount count: Int) {
        unreadCountSpy.append(MethodParams.UnreadCount(count: count))
    }

    func store(_ store: NotificationStore, didChangeUnseenCount count: Int) {
        unseenCountSpy.append(MethodParams.UnseenCount(count: count))
    }

    class MethodParams {
        struct TotalCount {
            let count: Int
        }

        struct UnreadCount {
            let count: Int
        }

        struct UnseenCount {
            let count: Int
        }
    }
}
