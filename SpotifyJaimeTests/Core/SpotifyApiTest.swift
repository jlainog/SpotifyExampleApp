//
//  SpotifyApiTest.swift
//  SpotifyJaimeTests
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import XCTest
@testable import SpotifyJaime

class SpotifyApiTest: XCTestCase {
    struct MockCodableObject : Codable {
        let title : String
    }
    
    func testParse_Success()  {
        let json = ["title" : "testTitle"]
        let result : Result<MockCodableObject> = SpotifyAPI.parse(json)
        
        result.value
            { object in
                XCTAssertEqual(object.title, "testTitle")
            }.error { _ in XCTFail() }
    }
    
    func testParse_Failure()  {
        let json = ["no_title" : "testTitle"]
        let result : Result<MockCodableObject> = SpotifyAPI.parse(json)
        
        result.error
            { error in
                guard case .keyNotFound(let key, _)? = error as? DecodingError else {
                    XCTFail()
                    return
                }
                
                XCTAssertEqual(key.stringValue, "title")
            }.value { _ in XCTFail() }
    }
}
