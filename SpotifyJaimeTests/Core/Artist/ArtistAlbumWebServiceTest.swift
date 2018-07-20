//
//  ArtistAlbumWebServiceTest.swift
//  SpotifyJaimeTests
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import XCTest
import OHHTTPStubs
@testable import SpotifyJaime

class ArtistAlbumWebServiceTest: XCTestCase {
    
    var jsonData : Data!
    var artist : Artist!
    
    override func setUp() {
        let path = Bundle.main.path(forResource: "ArtistsAlbumsResponse", ofType: "json")
        
        jsonData = try! Data.init(contentsOf: URL(fileURLWithPath: path!))
        getArtist()
    }

    func getArtist() {
        let path = Bundle.main.path(forResource: "SearchResponse", ofType: "json")
        let json = try! Data.init(contentsOf: URL(fileURLWithPath: path!))
        let searchList = try! JSONDecoder().decode(SearchList.self, from: json) as SearchList
        
        artist = searchList.artists.items.first
    }
    
    func testArtistAlbumWebService_Success() {
        stub(condition: isHost("api.spotify.com")) { _ in
            return OHHTTPStubsResponse(data: self.jsonData, statusCode: 200, headers: nil)
        }
        let waitForRequest = expectation(description: "testArtistAlbumWebService_Success")
        let service = ArtistWebService()
        
        stubSuccessToken()
        service.getAlbums(artist, page: 0) { (result) in
            let list = try! result.resolve()
            
            waitForRequest.fulfill()
            XCTAssertEqual(list.items.count, 2)
            XCTAssert(list.total == 527)
        }
        wait(for: [waitForRequest], timeout: 0.2)
    }
    
    func testArtistAlbumWebService_Failure() {
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
        let waitForRequest = expectation(description: "testArtistAlbumWebService_Failure")
        let service = ArtistWebService()
        
        stubSuccessToken()
        service.getAlbums(artist, page: 0) { (result) in
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
    
    func testArtistAlbumWebService_NoInternet() {
        stub(condition: isHost("api.spotify.com")) { _ in
            return OHHTTPStubsResponse(error: NSError(domain: NSURLErrorDomain,
                                                      code: NSURLErrorNotConnectedToInternet,
                                                      userInfo: nil))
        }
        let waitForRequest = expectation(description: "testArtistAlbumWebService_NoInternet")
        let service = ArtistWebService()
        
        stubSuccessToken()
        service.getAlbums(artist, page: 0) { (result) in
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
    
    func testArtistAlbumWebService_FailedToken() {
        let waitForRequest = expectation(description: "testArtistAlbumWebService_FailedToken")
        let service = ArtistWebService()
        
        stubFailureToken()
        service.getAlbums(artist, page: 0) { (result) in
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

extension ArtistAlbumWebServiceTest {
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
