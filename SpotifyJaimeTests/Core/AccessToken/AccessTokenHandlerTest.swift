//
//  AccessTokenHandler.swift
//  SpotifyJaimeTests
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import XCTest
@testable import SpotifyJaime

class AccessTokenHandlerTest: XCTestCase {
    
    var accessToken = MockAccessToken()
    
    func testAccessTokenHandler_SuccessRequest() {
        let waitForRequest = expectation(description: "testAccessTokenHandler_SuccessRequest")
        let service = MockAccessTokenService(testOption: .success(accessToken))
        let handler = MockAccessTokenHandler(service: service)
        
        handler.request { $0.value { (token) in
            waitForRequest.fulfill()
            XCTAssert(token.type == self.accessToken.type)
            }
        }
        wait(for: [waitForRequest], timeout: 0.2)
    }
    
    func testAccessTokenHandler_ValidToken() {
        let waitForRequest = expectation(description: "testAccessTokenHandler_ValidToken")
        let service = MockAccessTokenService(testOption: .success(accessToken))
        let handler = MockAccessTokenHandler(service: service)
        let validToken = MockAccessToken()
        
        validToken.expirationTime = 200
        validToken.type = "VALID"
        handler.token = validToken
        handler.request { $0.value { (token) in
            waitForRequest.fulfill()
            XCTAssertEqual(token.type, validToken.type)
            }
        }
        wait(for: [waitForRequest], timeout: 0.2)
    }
    
    func testAccessTokenHandler_ExpiredToken() {
        let waitForRequest = expectation(description: "testAccessTokenHandler_ExpiredToken")
        let service = MockAccessTokenService(testOption: .success(accessToken))
        let handler = MockAccessTokenHandler(service: service)
        let expiredToken = MockAccessToken()
        
        expiredToken.expirationTime = 0
        expiredToken.type = "EXPIRED"
        handler.token = expiredToken
        handler.request { $0.value { (token) in
            waitForRequest.fulfill()
            XCTAssertNotEqual(token.type, expiredToken.type)
            }
        }
        wait(for: [waitForRequest], timeout: 0.2)
    }
    
    func testAccessTokenHandler_Failure() {
        let waitForRequest = expectation(description: "testAccessTokenHandler_Failure")
        let mockError = "MockError"
        let service = MockAccessTokenService(testOption: .failure(mockError))
        let handler = MockAccessTokenHandler(service: service)
        
        handler.request { (result) in
            do {
                _ = try result.resolve()
                XCTFail()
            } catch {
                guard case let .failure(errorMessage)? = (error as? ServiceError) else {
                    XCTFail()
                    return
                }
                waitForRequest.fulfill()
                XCTAssertEqual(errorMessage, mockError)
            }
        }
        wait(for: [waitForRequest], timeout: 0.2)
    }
    
    func testAccessTokenHandler_NoInternet() {
        let waitForRequest = expectation(description: "testAccessTokenHandler_NoInternet")
        let service = MockAccessTokenService(testOption: .noInternetConnection)
        let handler = MockAccessTokenHandler(service: service)
        
        handler.request { (result) in
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
