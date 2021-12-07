//
//  AblyConnector.swift
//  MagicBell
//
//  Created by Javi on 2/12/21.
//

import Harmony
import Ably

class AblyConnector: StoreRealTime {

    private let getConfigInteractor: GetConfigInteractor
    private let userQueryInteractor: GetUserQueryInteractor
    private let environment: Environment
    private let logger: Logger

    private(set) var status: StoreRealTimeStatus = .disconnected
    private var ablyClient: ARTRealtime?

    private var observers = NSHashTable<AnyObject>.weakObjects()

    internal init(getConfigInteractor: GetConfigInteractor,
                  userQueryInteractor: GetUserQueryInteractor,
                  envinroment: Environment,
                  logger: Logger) {
        self.getConfigInteractor = getConfigInteractor
        self.userQueryInteractor = userQueryInteractor
        self.environment = envinroment
        self.logger = logger
    }

    private var reconnectionTimer: Timer?

    func startListening() {
        if status == .disconnected {
            self.status = .connecting
            connect()
        }
    }

    func stopListening() {
        disconnect()
        self.status = .disconnected
    }

    func addObserver(_ store: StoreRealTimeObserver) {
        observers.add(store)
    }

    func removeObserver(_ store: StoreRealTimeObserver) {
        observers.remove(store)
    }

    private func connect() {
        do {
            ablyClient?.connection.close()
            let userQuery = try userQueryInteractor.execute()
            getConfigInteractor.execute(forceRefresh: false, userQuery: userQuery).then { config in
                let options = ARTClientOptions()
                options.authUrl = URL(string: String(format: "%@/ws/auth", self.environment.baseUrl.absoluteString))
                options.authMethod = "POST"
                let headers = self.generateAblyHeaders(apiKey: self.environment.apiKey,
                                                       apiSecret: self.environment.apiSecret,
                                                       isHMACEnabled: self.environment.isHMACEnabled,
                                                       externalId: userQuery.externalId,
                                                       email: userQuery.email)
                options.authHeaders = headers

                // Establish connection
                self.ablyClient = ARTRealtime(options: options)

                // Listening connection changes
                self.startListenConnectionChanges()

                // Listening events
                self.startListeningMessages(channel: config.channel)
            }
        } catch {
            logger.info(tag: "AblyConnector", "\(error)")
        }
    }

    private func disconnect() {
        ablyClient?.connection.close()
        ablyClient = nil
        observers.removeAllObjects()
        stopReconnectionTimer()
    }

    private func generateAblyHeaders(apiKey: String,
                                     apiSecret: String,
                                     isHMACEnabled: Bool,
                                     externalId: String?,
                                     email: String?) -> [String: String] {

        var headers = ["X-MAGICBELL-API-KEY": apiKey]
        if isHMACEnabled {
            if let externalId = externalId {
                let hmac = externalId.hmac(key: apiSecret)
                headers["X-MAGICBELL-USER-HMAC"] = hmac
            } else if let email = email {
                let hmac = email.hmac(key: apiSecret)
                headers["X-MAGICBELL-USER-HMAC"] = hmac
            }
        }
        if let externalId = externalId {
            headers["X-MAGICBELL-USER-EXTERNAL-ID"] = externalId
        }
        if let email = email {
            headers["X-MAGICBELL-USER-EMAIL"] = email
        }
        return headers
    }

    private func startListenConnectionChanges() {
        // Listen connection events
        self.ablyClient?.connection.on { stateChange in
            print(stateChange)
            let stateChange = stateChange
            switch stateChange.current {
            case .initialized, .connecting:
                self.stopReconnectionTimer()
            case .connected:
                self.status = .connected
                self.stopReconnectionTimer()
            default:
                if self.status != .disconnected {
                    self.status = .connecting
                    self.startReconnectionTimer()
                }
            }
        }
    }

    private func startListeningMessages(channel: String) {
        let channel = ablyClient?.channels.get(channel)
        channel?.subscribe { message in
            self.processAblyMessage(message)
        }
    }

    private func processAblyMessage(_ message: ARTMessage) {
        if let event = message.name,
           let eventData = message.data as? [String: String?] {
            let eventParts = event.split(separator: "/", maxSplits: 1)
            if !eventParts.isEmpty &&
                eventParts.count == 2 &&
                eventParts[0] == "notifications" {
                switch eventParts[1] {
                case "new":
                    if let notificationId = eventData["id"] as? String {
                        sendAllObservers { $0.notifyNewNotification(id: notificationId) }
                    } else {
                        logger.info(tag: "AblyConnector", "NotificationID is missing in the JSON")
                    }
                case "read":
                    if let notificationId = eventData["id"] as? String {
                        sendAllObservers { $0.notifyNotificationChange(id: notificationId, change: .read) }
                    } else {
                        logger.info(tag: "AblyConnector", "NotificationID is missing in the JSON")
                    }
                case "unread":
                    if let notificationId = eventData["id"] as? String {
                        sendAllObservers { $0.notifyNotificationChange(id: notificationId, change: .unread) }
                    } else {
                        logger.info(tag: "AblyConnector", "NotificationID is missing in the JSON")
                    }
                case "delete":
                    if let notificationId = eventData["id"] as? String {
                        sendAllObservers { $0.notifyDeleteNotification(id: notificationId) }
                    } else {
                        logger.info(tag: "AblyConnector", "NotificationID is missing in the JSON")
                    }
                case "read/all":
                    sendAllObservers { $0.notifyAllNotificationRead() }
                case "seen/all":
                    sendAllObservers { $0.notifyAllNotificationSeen() }
                default:
                    logger.info(tag: "AblyConnector", "Event unprocessed \(event)")
                }
            } else {
                logger.info(tag: "AblyConnector", "Event unprocessed \(event)")
            }
        } else {
            logger.info(tag: "AblyConnector", "Message unprocessed \(message)")
        }
    }

    private func sendAllObservers(block: (StoreRealTimeObserver) -> Void) {
        observers.allObjects
            .compactMap { $0 as? StoreRealTimeObserver }
            .forEach { block($0) }
    }

    private func startReconnectionTimer() {
        reconnectionTimer?.invalidate()
        reconnectionTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            self?.connect()
        }
    }

    private func stopReconnectionTimer() {
        reconnectionTimer?.invalidate()
    }
}
