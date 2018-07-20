//
//  SearchServiceTest.swift
//  SpotifyJaimeTests
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import XCTest
@testable import SpotifyJaime

class SearchServiceTest: XCTestCase {
    
    var list : SearchList!
    
    override func setUp() {
        let path = Bundle.main.path(forResource: "SearchResponse", ofType: "json")
        let json = try! Data.init(contentsOf: URL(fileURLWithPath: path!))
        let searchList = try! JSONDecoder().decode(SearchList.self, from: json) as SearchList
        
        list = searchList
    }
    
    func testSearchService_Success() {
        let waitForRequest = expectation(description: "testSearchService_Success")
        let service = MockSearchService(testOption: .success(list))
        
        service.search("searchTerm") { (result) in
            let list = try! result.resolve()
            
            waitForRequest.fulfill()
            XCTAssert(list.artists.items.count == 4)
            XCTAssert(list.albums?.items.count == 4)
        }
        wait(for: [waitForRequest], timeout: 0.2)
    }
    
    func testSearchService_Failure() {
        let waitForRequest = expectation(description: "testSearchService_Failure")
        let mockError = "MockError"
        let service = MockSearchService(testOption: .failure(mockError))
        
        service.search("searchTerm") { (result) in
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
    
    func testSearchService_NoInternet() {
        let waitForRequest = expectation(description: "testSearchService_NoInternet")
        let service = MockSearchService(testOption: .noInternetConnection)
        
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
        wait(for: [waitForRequest], timeout: 0.2)
    }
    
}
