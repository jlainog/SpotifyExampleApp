//
//  SpotifyAccessTokenServiceTest.swift
//  SpotifyJaimeTests
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import XCTest
import OHHTTPStubs
@testable import SpotifyJaime

class SpotifyAccessTokenServiceTest: XCTestCase {
    func testAccessTokenService_NotInternetConnection() {
        stub(condition: isHost("accounts.spotify.com")) { _ in
            return OHHTTPStubsResponse(error: NSError(domain: NSURLErrorDomain,
                                                      code: NSURLErrorNotConnectedToInternet,
                                                      userInfo: nil))
        }
        let waitingForService = expectation(description: "testAccessTokenService_NotInternetConnection")
        let service = SpotifyAccessTokenService()
        
        service.request {
            $0.error {
                (err) in
                if case .noInternetConnection? = (err as? ServiceError) {
                    print("#### Correct: Not Connected to Internet ####")
                } else {
                    XCTFail("### Fail: Not Connected to Internet ###")
                }
                waitingForService.fulfill()
            }
        }
        waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    func testAccessTokenService_Failure() {
        stub(condition: isHost("accounts.spotify.com")) { _ in
            return OHHTTPStubsResponse(jsonObject:
                ["error":
                    ["status" : 200,
                     "message" : "MockError"
                    ]
                ],
                                       statusCode: 401,
                                       headers: nil)
        }
        let waitingForService = expectation(description: "testAccessTokenService_Failure")
        let service = SpotifyAccessTokenService()
        
        service.request {
            $0.error {
                (err) in
                if case ServiceError.failure(let message)? = (err as? ServiceError) {
                    XCTAssertEqual(message, "200 - MockError")
                } else {
                    XCTFail("### Fail: Not Connected to Internet ###")
                }
                waitingForService.fulfill()
            }
        }
        waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    func testAccessTokenService_Success() {
        func testSuccessResponse() {
            let accessToken = MockAccessToken() 
            stub(condition: isHost("accounts.spotify.com")) { _ in
                let mockTokenResponse: [String : Any] = [
                    "expirationTime" : accessToken.expirationTime,
                    "requestedAt" : accessToken.requestedAt,
                    "type" : accessToken.type,
                    "value" : accessToken.value
                ]
                return OHHTTPStubsResponse(jsonObject: mockTokenResponse,
                                           statusCode: 200,
                                           headers: nil)
            }
            
            let waitingForService = expectation(description: "testAccessTokenService_Success")
            let service = SpotifyAccessTokenService()
            
            service.request {
                $0.value { (token) in
                    XCTAssertEqual(token.type, accessToken.type)
                    waitingForService.fulfill()
                }
            }
            waitForExpectations(timeout: 5, handler: nil)
        }
    }
    
    func testBuildToken_Success() {
        let jsonToken = [ "access_token" : "token",
                          "token_type" : "BEER",
                          "expires_in" : 200
            ] as [String : Any]
        let service = SpotifyAccessTokenService()
     
        service.buildToken(jsonToken).value { (token) in
            XCTAssertEqual(token.expirationTime, 200)
            XCTAssertEqual(token.value, "token")
            XCTAssertEqual(token.type, "BEER")
            }.error { _ in XCTFail() }
    }

    func testBuildToken_Failure() {
        let jsonToken = [ "access_token" : "token",
                          "token_type" : "BEER",
            ] as [String : Any]
        let service = SpotifyAccessTokenService()
        
        service.buildToken(jsonToken).error { err in
            guard case ServiceError.failure(let message)? = (err as? ServiceError) else {
                XCTFail()
                return
            }
            
            XCTAssertEqual(message, "Something went wrong")
            }.value { _ in XCTFail() }
    }
}
