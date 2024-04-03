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

@testable import MagicBell

import XCTest
import Nimble

final class UserPreferencesEntityTests: XCTestCase {
    let mapper = DataToDecodableMapper<UserPreferencesEntity>()
    
    func testJsonDecoding() throws {
        let bundle = Bundle(for: type(of: self))
        
        guard let url = bundle.url(forResource: "NotificationPreferences", withExtension: "json") else {
            XCTFail("Missing file: NotificationPreferences.json")
            return
        }
        
        let json = try Data(contentsOf: url)
        
        let entity = try! mapper.map(json)
    }
}
