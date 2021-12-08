//
//  SendPushSubscriptionInteractor.swift
//  MagicBell
//
//  Created by Javi on 8/12/21.
//

import Harmony

struct SendPushSubscriptionInteractor {

    private let executor: Executor
    private let getUserQueryInteractor: GetUserQueryInteractor
    private let getDeviceTokenInteractor: Interactor.GetByQuery<String>
    private let putPushSubscriptionInteractor: Interactor.PutByQuery<PushSubscription>

    init(
        executor: Executor,
        getUserQueryInteractor: GetUserQueryInteractor,
        getDeviceTokenInteractor: Interactor.GetByQuery<String>,
        putPushSubscriptionInteractor: Interactor.PutByQuery<PushSubscription>
    ) {
        self.executor = executor
        self.getUserQueryInteractor = getUserQueryInteractor
        self.getDeviceTokenInteractor = getDeviceTokenInteractor
        self.putPushSubscriptionInteractor = putPushSubscriptionInteractor
    }

    func execute() -> Future<PushSubscription> {
        return executor.submit { resolver in
            let userQuery = try getUserQueryInteractor.execute()
            let deviceToken: String
            do {
                deviceToken = try getDeviceTokenInteractor.execute(DeviceTokenQuery(), in: DirectExecutor()).result.get()
            } catch is CoreError.NotFound {
                throw MagicBellError("APN Token is not available")
            } catch {
                throw error
            }

            let pushSubscription = PushSubscription(id: nil, deviceToken: deviceToken, platform: "ios")
            let pushSubscriptionQuery = RegisterPushSubscriptionQuery(user: userQuery)

            resolver.set(putPushSubscriptionInteractor.execute(pushSubscription, query: pushSubscriptionQuery, in: DirectExecutor()))
        }
    }
}
