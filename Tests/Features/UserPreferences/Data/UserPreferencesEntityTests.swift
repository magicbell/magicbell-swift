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

let mockResponse = """
{
   "notification_preferences":{
      "categories":[
         {
            "label":"User Liked Post",
            "slug":"user_liked_post",
            "channels":[
               {
                  "label":"In app",
                  "slug":"in_app",
                  "enabled":true
               },
               {
                  "label":"Mobile push",
                  "slug":"mobile_push",
                  "enabled":false
               }
            ]
         }
       ]
    }
}
"""

final class UserPreferencesEntityTests: XCTestCase {
    let mapper = DataToDecodableMapper<UserPreferencesEntity>()
    
    func testJsonDecoding() throws {
        
        let json = mockResponse.data(using: .utf8)!
        
        let entity = try! mapper.map(json)
        
        XCTAssertEqual(entity.categories.count, 1)
        
        let category = entity.categories.first!
        XCTAssertEqual(category.label, "User Liked Post")
        XCTAssertEqual(category.slug, "user_liked_post")
        XCTAssertEqual(category.channels.count, 2)
        
        let channel1 = category.channels[0]
        XCTAssertTrue(channel1.enabled)
        XCTAssertEqual(channel1.label, "In app")
        XCTAssertEqual(channel1.slug, "in_app")
        
        let channel2 = category.channels[1]
        XCTAssertFalse(channel2.enabled)
        XCTAssertEqual(channel2.label, "Mobile push")
        XCTAssertEqual(channel2.slug, "mobile_push")
    }
}
