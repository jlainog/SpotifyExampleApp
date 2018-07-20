//
//  ArtistServiceTest.swift
//  SpotifyJaimeTests
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import XCTest
@testable import SpotifyJaime

class ArtistServiceTest: XCTestCase {
    
    var artistsList : ArtistList!
    
    override func setUp() {
        let path = Bundle.main.path(forResource: "SearchResponse", ofType: "json")
        let json = try! Data.init(contentsOf: URL(fileURLWithPath: path!))
        let searchList = try! JSONDecoder().decode(SearchList.self, from: json) as SearchList
        
        artistsList = searchList.artists
    }
    
    func testSearchArtistService_Success() {
        let waitForRequest = expectation(description: "testSearchArtistService_Success")
        let service = MockArtistService(testOption: .success(artistsList))
        
        service.search("searchTerm", page: 0) { (result) in
            let list = try! result.resolve()
            
            waitForRequest.fulfill()
            XCTAssert(list.items.count == 4)
            XCTAssert(list.total == 208)
        }
        wait(for: [waitForRequest], timeout: 0.2)
    }
    
    func testSearchArtistService_Failure() {
        let waitForRequest = expectation(description: "testSearchArtistService_Failure")
        let mockError = "MockError"
        let service = MockArtistService(testOption: .failure(mockError))
        
        service.search("searchTerm", page: 0) { (result) in
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
    
    func testSearchArtistService_NoInternet() {
        let waitForRequest = expectation(description: "testSearchArtistService_NoInternet")
        let service = MockArtistService(testOption: .noInternetConnection)
        
        service.search("searchTerm", page: 0) { (result) in
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
