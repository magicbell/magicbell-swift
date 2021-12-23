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

protocol StoreRealTime {
    func startListening(with config: Config)
    func stopListening()
    func addObserver(_ observer: StoreRealTimeObserver)
    func removeObserver(_ observer: StoreRealTimeObserver)
}

enum StoreRealTimeStatus {
    case connecting
    case connected
    case disconnected
}

protocol StoreRealTimeObserver: AnyObject {
    func notifyNewNotification(id: String)
    func notifyDeleteNotification(id: String)
    func notifyNotificationChange(id: String, change: StoreRealTimeNotificationChange)
    func notifyAllNotificationRead()
    func notifyAllNotificationSeen()
    func notifyReloadStore()
}

enum StoreRealTimeNotificationChange {
    case read
    case unread
}
