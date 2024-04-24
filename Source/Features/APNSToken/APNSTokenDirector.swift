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
import Harmony

protocol APNSTokenDirector {
    /// Registers an APNS token
    func registerAPNSToken(_ deviceToken: String)
    
    /// Deletes an APNS token on logout
    func deleteAPNSToken(_ deviceToken: String)
}

class DefaultAPNSTokenDirector: APNSTokenDirector {
    private let logger: Logger
    private let userQuery: UserQuery
    private let registerAPNSTokenInteractor: RegisterAPNSTokenInteractor
    private let deleteAPNSTokenInteractor: DeleteAPNSTokenInteractor
    
    init(
        logger: Logger,
        userQuery: UserQuery,
        registerAPNSTokenInteractor: RegisterAPNSTokenInteractor,
        deleteAPNSTokenInteractor: DeleteAPNSTokenInteractor
    ) {
        self.logger = logger
        self.userQuery = userQuery
        self.registerAPNSTokenInteractor = registerAPNSTokenInteractor
        self.deleteAPNSTokenInteractor = deleteAPNSTokenInteractor
    }
    
    func registerAPNSToken(_ deviceToken: String) {
        registerAPNSTokenInteractor
            .execute(deviceToken: deviceToken, userQuery: userQuery)
            .then { apnsToken in
                self.logger.info(tag: magicBellTag, "APNS token was registered \(apnsToken)")
            }.fail { error in
                self.logger.info(tag: magicBellTag, "Registering APNS token failed: \(error.localizedDescription)")
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) { [weak self] in
                    self?.registerAPNSToken(deviceToken)
                }
            }
    }
    
    func deleteAPNSToken(_ deviceToken: String) {
        deleteAPNSTokenInteractor
            .execute(deviceToken: deviceToken, userQuery: userQuery)
            .then { apnsToken in
                self.logger.info(tag: magicBellTag, "APNS token was deleted \(apnsToken)")
            }.fail { error in
                self.logger.info(tag: magicBellTag, "Deleting APNS token failed: \(error.localizedDescription)")
            }
    }
}
