//
//  AccessTokenServiceTest.swift
//  SpotifyJaimeTests
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import XCTest
@testable import SpotifyJaime

class MockAccessToken: AccessToken {
    var expirationTime: Int = 0
    var requestedAt: Date = Date()
    var type: String = "MOCK"
    var value: String = "1324"
}

class AccessTokenServiceTest: XCTestCase {
    
    var accessToken = MockAccessToken()
    
    func testRequestAccessToken_Success() {
        let waitForRequest = expectation(description: "testRequestAccessToken_Success")
        let service = MockAccessTokenService(testOption: .success(accessToken))
        
        service.request { (result) in
            let token = try! result.resolve()
            
            waitForRequest.fulfill()
            XCTAssert(token.type == self.accessToken.type)
        }
        wait(for: [waitForRequest], timeout: 0.2)
    }
    
    func testRequestAccessToken_Failure() {
        let waitForRequest = expectation(description: "testRequestAccessToken_Failure")
        let mockError = "MockError"
        let service = MockAccessTokenService(testOption: .failure(mockError))
        
        service.request { (result) in
            result.error { err in
                guard case let .failure(errorMessage)? = (err as? ServiceError) else {
                    XCTFail()
                    return
                }
                waitForRequest.fulfill()
                XCTAssertEqual(errorMessage, mockError)
                }.value { _ in XCTFail() }
        }
        wait(for: [waitForRequest], timeout: 0.2)
    }
    
    func testRequestAccessToken_NoInternet() {
        let waitForRequest = expectation(description: "testRequestAccessToken_NoInternet")
        let service = MockAccessTokenService(testOption: .noInternetConnection)
        
        service.request { (result) in
            do {
                _ = try result.resolve()
                XCTFail()
            } catch {
                guard case .noInternetConnection? = (error as? ServiceError) else {
                    XCTFail()
                    return
                }
                waitForRequest.fulfill()
            }
        }
        wait(for: [waitForRequest], timeout: 0.2)
    }
    
}
