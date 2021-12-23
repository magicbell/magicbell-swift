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

import Foundation
@testable import MagicBell

class StoreRealTimeMock: StoreRealTime {

    enum Event {
        case newNotification(id: String)
        case deleteNotification(id: String)
        case readNotification(id: String)
        case unreadNotification(id: String)
        case readAllNotification
        case seenAllNotification
        case reloadStore
    }

    var observers = NSHashTable<AnyObject>.weakObjects()
    private(set) var events: [MethodParams.ProcessMessage] = []

    func startListening(with config: Config) { }

    func stopListening() { }

    func addObserver(_ observer: StoreRealTimeObserver) {
        observers.add(observer)
    }

    func removeObserver(_ observer: StoreRealTimeObserver) {
        observers.remove(observer)
    }

    func processMessage(event: Event) {
        events.append(MethodParams.ProcessMessage(event: event))
        forEachObserver { observer in
            switch event {
            case .newNotification(let id):
                observer.notifyNewNotification(id: id)
            case .deleteNotification(let id):
                observer.notifyDeleteNotification(id: id)
            case .readNotification(let id):
                observer.notifyNotificationChange(id: id, change: .read)
            case .unreadNotification(let id):
                observer.notifyNotificationChange(id: id, change: .unread)
            case .readAllNotification:
                observer.notifyAllNotificationRead()
            case .seenAllNotification:
                observer.notifyAllNotificationSeen()
            case .reloadStore:
                observer.notifyReloadStore()
            }
        }
    }

    private func forEachObserver(block: (StoreRealTimeObserver) -> Void) {
        observers.allObjects.forEach {
            if let storeRealTimeObserver = $0 as? StoreRealTimeObserver {
                block(storeRealTimeObserver)
            }
        }
    }

    class MethodParams {
        struct ProcessMessage {
            let event: Event
        }
    }
}
