//
//  String+HMAC.swift
//  MagicBell
//
//  Created by Javi on 17/11/21.
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
