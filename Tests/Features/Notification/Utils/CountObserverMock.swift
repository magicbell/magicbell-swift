//
//  CountObserverMock.swift
//  MagicBellTests
//
//  Created by Javi on 21/12/21.
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
