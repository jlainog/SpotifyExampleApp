//
//  SearchArtistControllerTest.swift
//  SpotifyJaimeTests
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import XCTest
@testable import SpotifyJaime

fileprivate class MockSearchArtistControllerDelegate : SearchArtistControllerDelegate {
    var didCallArtistload : Bool = false
    var didCallFailLoad : Bool = false
    
    func didFail() {
        didCallFailLoad = true
    }
    
    func didLoadArtists() {
        didCallArtistload = true
    }
}

class SearchArtistControllerTest: XCTestCase {
    var artistsList : ArtistList!
    
    override func setUp() {
        let path = Bundle.main.path(forResource: "SearchResponse", ofType: "json")
        let json = try! Data.init(contentsOf: URL(fileURLWithPath: path!))
        let searchList = try! JSONDecoder().decode(SearchList.self, from: json) as SearchList
        
        artistsList = searchList.artists
    }
    
    func testSearch_Success() {
        let waitForRequest = expectation(description: "testSearch_Success")
        let service = MockArtistService(testOption: .success(artistsList))
        let controller = SearchArtistController(service: service)
        let delegate = MockSearchArtistControllerDelegate()
        
        controller.delegate = delegate
        controller.search(byQuery: "mock")
        XCTAssertTrue(delegate.didCallArtistload)
        XCTAssertFalse(delegate.didCallFailLoad)
        DispatchQueue.main.async {
            waitForRequest.fulfill()
            XCTAssertEqual(controller.artists.count, 4)
            XCTAssertEqual(controller.page, 1)
            XCTAssert(controller.showNoFoundArtists == false)
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    
    func testSearch_NextPage() {
        let waitForRequest = expectation(description: "testSearch_NextPage")
        let service = MockArtistService(testOption: .success(artistsList))
        let controller = SearchArtistController(service: service)
        let delegate = MockSearchArtistControllerDelegate()
        
        XCTAssertEqual(controller.initialPage, controller.page)
        controller.delegate = delegate
        controller.search(byQuery: "mock")
        XCTAssertTrue(delegate.didCallArtistload)
        XCTAssertEqual(controller.initialPage + 1, controller.page)
        controller.fetchNextPage()
        controller.fetchNextPage()
        DispatchQueue.main.async { [weak controller] in
            XCTAssertEqual(controller?.page, 3)
            XCTAssertFalse(controller?.retrevingResults ?? true)
            XCTAssertFalse(controller?.showNoFoundArtists ?? true)
            waitForRequest.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testSearch_Failure() {
        let waitForRequest = expectation(description: "testSearch_Failure")
        let service = MockArtistService(testOption: .noInternetConnection)
        let controller = SearchArtistController(service: service)
        let delegate = MockSearchArtistControllerDelegate()
        
        controller.delegate = delegate
        controller.search(byQuery: "mock")
        XCTAssertFalse(delegate.didCallArtistload)
        XCTAssertTrue(delegate.didCallFailLoad)
        DispatchQueue.main.async { [weak controller] in
            XCTAssertTrue(controller?.showNoFoundArtists ?? false)
            XCTAssertEqual(controller?.errorMessage, ServiceError.noInternetConnection.localizedDescription)
            waitForRequest.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
}
