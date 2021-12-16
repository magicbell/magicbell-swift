//
//  StoreRealTime.swift
//  MagicBell
//
//  Created by Javi on 3/12/21.
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
