//
//  SearchControllerTest.swift
//  SpotifyJaimeTests
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import XCTest
@testable import SpotifyJaime

fileprivate class MockSearchControllerDelegate : SearchControllerDelegate {
    var didCallResultsLoad : Bool = false
    var didCallFailLoad : Bool = false
    
    func didFail() {
        didCallFailLoad = true
    }
    
    func didLoadResults() {
        didCallResultsLoad = true
    }
}

class SearchControllerTest: XCTestCase {
    
    var list : SearchList!
    
    override func setUp() {
        let path = Bundle.main.path(forResource: "SearchResponse", ofType: "json")
        let json = try! Data.init(contentsOf: URL(fileURLWithPath: path!))
        let searchList = try! JSONDecoder().decode(SearchList.self, from: json) as SearchList
        
        list = searchList
    }
    
    func testSearch_Success() {
        let waitForRequest = expectation(description: "testSearch_Success")
        let service = MockSearchService(testOption: .success(list))
        let controller = SearchController(service: service)
        let delegate = MockSearchControllerDelegate()
        
        controller.delegate = delegate
        controller.search(byQuery: "mock")
        XCTAssertTrue(delegate.didCallResultsLoad)
        XCTAssertFalse(delegate.didCallFailLoad)
        DispatchQueue.main.async {
            waitForRequest.fulfill()
            XCTAssertEqual(controller.sections.count, 3)
            XCTAssert(controller.showNotFoundResults == false)
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
     
    func testSearch_Failure() {
        let waitForRequest = expectation(description: "testSearch_Failure")
        let service = MockSearchService(testOption: .noInternetConnection)
        let controller = SearchController(service: service)
        let delegate = MockSearchControllerDelegate()
        
        controller.delegate = delegate
        controller.search(byQuery: "mock")
        XCTAssertFalse(delegate.didCallResultsLoad)
        XCTAssertTrue(delegate.didCallFailLoad)
        DispatchQueue.main.async { [weak controller] in
            XCTAssertEqual(controller?.sections.count, 0)
            XCTAssertTrue(controller?.showNotFoundResults ?? false)
            XCTAssertEqual(controller?.errorMessage, ServiceError.noInternetConnection.localizedDescription)
            waitForRequest.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
}
