//
//  SearchWebServiceTest.swift
//  SpotifyJaimeTests
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import XCTest
import OHHTTPStubs
@testable import SpotifyJaime

class SearchWebServiceTest: XCTestCase {
    
    var jsonData : Data!
    
    override func setUp() {
        let path = Bundle.main.path(forResource: "SearchResponse", ofType: "json")
        
        jsonData = try! Data.init(contentsOf: URL(fileURLWithPath: path!))
    }
    
    func testSearchService_Success() {
        stub(condition: isHost("api.spotify.com")) { _ in
            return OHHTTPStubsResponse(data: self.jsonData, statusCode: 200, headers: nil)
        }
        let waitForRequest = expectation(description: "testSearchService_Success")
        let service = SearchWebService()
        
        service.search("searchTerm") { (result) in
            let list = try! result.resolve()
            
            waitForRequest.fulfill()
            XCTAssert(list.albums?.items.count == 4)
            XCTAssert(list.artists.items.count == 4)
        }
        wait(for: [waitForRequest], timeout: 0.2)
    }
    
    func testSearchService_Failure() {
        stub(condition: isHost("api.spotify.com")) { _ in
            return OHHTTPStubsResponse(jsonObject:
                ["error":
                    ["status" : 200,
                     "message" : "MockError"
                    ]
                ],
                                       statusCode: 401,
                                       headers: nil)
        }
        let waitForRequest = expectation(description: "testSearchService_Failure")
        let service = SearchWebService()
        
        stubSuccessToken()
        service.search("searchTerm") { (result) in
            result.error { err in
                guard case let .failure(errorMessage)? = (err as? ServiceError) else {
                    XCTFail()
                    return
                }
                waitForRequest.fulfill()
                XCTAssertEqual(errorMessage, "200 - MockError")
                }.value { _ in XCTFail() }
        }
        wait(for: [waitForRequest], timeout: 0.2)
    }
    
    func testSearchService_NoInternet() {
        stub(condition: isHost("api.spotify.com")) { _ in
            return OHHTTPStubsResponse(error: NSError(domain: NSURLErrorDomain,
                                                      code: NSURLErrorNotConnectedToInternet,
                                                      userInfo: nil))
        }
        let waitForRequest = expectation(description: "testSearchService_NoInternet")
        let service = SearchWebService()
        
        stubSuccessToken()
        service.search("searchTerm") { (result) in
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
        wait(for: [waitForRequest], timeout: 1.0)
    }
    
    func testSearchService_FailedToken() {
        let waitForRequest = expectation(description: "testSearchService_FailedToken")
        let service = SearchWebService()
        
        stubFailureToken()
        service.search("searchTerm") { (result) in
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
        wait(for: [waitForRequest], timeout: 1.0)
    }
}

extension SearchWebServiceTest {
    func stubFailureToken() {
        stub(condition: isHost("accounts.spotify.com")) { _ in
            return OHHTTPStubsResponse(error: NSError(domain: NSURLErrorDomain,
                                                      code: NSURLErrorNotConnectedToInternet,
                                                      userInfo: nil))
        }
    }
    
    func stubSuccessToken() {
        let accessToken = MockAccessToken()
        stub(condition: isHost("accounts.spotify.com")) { _ in
            let mockTokenResponse: [String : Any] = [
                "expires_in" : accessToken.expirationTime,
                "token_type" : accessToken.type,
                "access_token" : accessToken.value
            ]
            return OHHTTPStubsResponse(jsonObject: mockTokenResponse,
                                       statusCode: 200,
                                       headers: nil)
        }
    }
}
