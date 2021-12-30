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

import Harmony
import Ably

class AblyConnector: StoreRealTime {
    
    private let tag = "AblyConnector"
    
    private let getConfigInteractor: GetConfigInteractor

    private let environment: Environment
    private let logger: Logger
    private let userQuery: UserQuery
    
    private(set) var status: StoreRealTimeStatus = .disconnected
    private var ablyClient: ARTRealtime?
    private var config: Config?
    
    private var observers = NSHashTable<AnyObject>.weakObjects()
    
    init(getConfigInteractor: GetConfigInteractor,
         userQuery: UserQuery,
         environment: Environment,
         logger: Logger) {
        self.getConfigInteractor = getConfigInteractor
        self.userQuery = userQuery
        self.environment = environment
        self.logger = logger
    }
    
    private var reconnectionTimer: Timer?

    func startListening(with config: Config) {
        self.config = config
        if status == .disconnected {
            status = .connecting
            connect(config)
        }
    }
    
    func stopListening() {
        disconnect()
        status = .disconnected
    }
    
    func addObserver(_ store: StoreRealTimeObserver) {
        observers.add(store)
    }
    
    func removeObserver(_ store: StoreRealTimeObserver) {
        observers.remove(store)
    }
    
    private func connect(_ config: Config) {
        ablyClient?.connection.close()
        let options = ARTClientOptions()
        options.authUrl = URL(string: String(format: "%@/ws/auth", self.environment.baseUrl.absoluteString))
        options.authMethod = "POST"
        let headers = self.generateAblyHeaders(
            apiKey: self.environment.apiKey,
            apiSecret: self.environment.apiSecret,
            isHMACEnabled: self.environment.isHMACEnabled,
            externalId: self.userQuery.externalId,
            email: self.userQuery.email
        )
        options.authHeaders = headers

        // Establish connection
        self.ablyClient = ARTRealtime(options: options)

        // Listening connection changes
        self.startListenConnectionChanges()

        // Listening events
        self.startListeningMessages(channel: config.channel)
    }

    private func disconnect() {
        reconnectionTimer?.invalidate()
        reconnectionTimer = nil
        ablyClient?.connection.close()
        ablyClient = nil
        observers.removeAllObjects()
    }

    private func generateAblyHeaders(
        apiKey: String,
        apiSecret: String?,
        isHMACEnabled: Bool,
        externalId: String?,
        email: String?
    ) -> [String: String] {

        var headers = ["X-MAGICBELL-API-KEY": apiKey]
        if let apiSecret = apiSecret,
           isHMACEnabled {
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
            let stateChange = stateChange
            switch stateChange.current {
            case .initialized, .connecting:
                break
            case .connected:
                self.status = .connected
            case .disconnected:
                self.status = .connecting
                self.logger.info(tag: self.tag, "Ably is disconnected. Retrying every 15 seconds.")
            case .suspended:
                self.status = .connecting
                self.logger.info(tag: self.tag, "Ably is suspended. Retrying every 30 seconds.")
            case .closed:
                if self.status != .disconnected,
                    let config = self.config {
                    // As ably connection cannot be stablished, notify stores to reload themselves to keep data in sync
                    self.forEachObserver { $0.notifyReloadStore() }
                    self.status = .connecting
                    self.connect(config)
                }
            default:
                break
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
        do {
            let ablyMessageProcessor = AblyMessageProcessor(logger: logger)
            let message = try ablyMessageProcessor.processAblyMessage(message)

            switch message {
            case .new(let notificationId):
                forEachObserver { $0.notifyNewNotification(id: notificationId) }
            case .read(let notificationId):
                forEachObserver { $0.notifyNotificationChange(id: notificationId, change: .read) }
            case .unread(let notificationId):
                forEachObserver { $0.notifyNotificationChange(id: notificationId, change: .unread) }
            case .delete(let notificationId):
                forEachObserver { $0.notifyDeleteNotification(id: notificationId) }
            case .archived(let notificationId):
                forEachObserver { $0.notifyNotificationChange(id: notificationId, change: .archive) }
            case .readAll:
                forEachObserver { $0.notifyAllNotificationRead() }
            case .seenAll:
                forEachObserver { $0.notifyAllNotificationSeen() }
            }
        } catch {
            logger.info(tag: tag, error.localizedDescription)
        }
    }

    private func forEachObserver(block: (StoreRealTimeObserver) -> Void) {
        observers.allObjects.forEach {
            if let storeRealTimeObserver = $0 as? StoreRealTimeObserver {
                block(storeRealTimeObserver)
            }
        }
    }
}
