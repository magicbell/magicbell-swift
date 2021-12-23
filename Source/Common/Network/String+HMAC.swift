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
import CommonCrypto

extension String {
    func hmac(key: String) -> String {
        let cKey = key.cString(using: String.Encoding.utf8)
        let cData = cString(using: String.Encoding.utf8)
        var result = [CUnsignedChar](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        if let cKey = cKey,
           let cData = cData {
            CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), cKey, strlen(cKey), cData, strlen(cData), &result)
            let hmacData = NSData(bytes: result, length: Int(CC_SHA256_DIGEST_LENGTH))
            let hmacBase64 = hmacData.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength76Characters)
            return String(hmacBase64)
        } else {
            return ""
        }
    }
}
