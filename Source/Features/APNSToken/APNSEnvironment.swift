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

enum APNSEnvironment: String, Codable {
    case development
    case production
}


extension APNSEnvironment {
    
    static var currentEnviroment: APNSEnvironment {
        get {
            // Inspired by Expo
            // https://github.com/expo/expo/blob/c158ef23812c2995f326c51565b189e234948885/packages/expo-application/ios/EXApplication/EXProvisioningProfile.m#L28 (MIT License)
            // and https://github.com/doneservices/ApsEnvironment/blob/221afddd19be77f9a5a943be637a8cc7e9dfeb94/Sources/ApsEnvironment/ApsEnvironment.swift#L4 (MIT License)
            guard
                let filePath = Bundle.main.path(forResource: "embedded", ofType:"mobileprovision"),
                let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)),
                let open = data.range(of: "<plist".data(using: .ascii)!),
                let close = data.range(of: "</plist>".data(using: .ascii)!, options: [], in: open.lowerBound..<data.endIndex),
                let rawPlist = try? PropertyListSerialization.propertyList(from: data[open.lowerBound..<close.upperBound], options: [], format: nil),
                let plist = rawPlist as? [String: AnyObject],
                let entitlements = plist["Entitlements"] as? [String: AnyObject],
                let environment = entitlements["aps-environment"] as? String else {
                return .development // fallback to development
            }
            return APNSEnvironment(rawValue: environment) ?? .development
        }
    }
}
