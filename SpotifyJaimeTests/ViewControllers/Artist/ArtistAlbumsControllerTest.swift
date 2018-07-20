//
//  ArtistAlbumsControllerTest.swift
//  SpotifyJaimeTests
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import XCTest
@testable import SpotifyJaime

fileprivate class MockArtistAlbumsDelegate : ArtistAlbumsControllerDelegate {
    var didCallAlbumsload : Bool = false
    var didCallFailLoad : Bool = false
    
    func didFail() {
        didCallFailLoad = true
    }
    
    func didLoadAlbums() {
        didCallAlbumsload = true
    }
}

class ArtistAlbumsControllerTest: XCTestCase {
    var list : AlbumsList!
    var artist : Artist!
    
    override func setUp() {
        getArtist()
        getAlbumsList()
    }
    
    func getAlbumsList() {
        let path = Bundle.main.path(forResource: "ArtistsAlbumsResponse", ofType: "json")
        let json = try! Data.init(contentsOf: URL(fileURLWithPath: path!))
        let list = try! JSONDecoder().decode(AlbumsList.self, from: json) as AlbumsList
        
        self.list = list
    }
    
    func getArtist() {
        let path = Bundle.main.path(forResource: "SearchResponse", ofType: "json")
        let json = try! Data.init(contentsOf: URL(fileURLWithPath: path!))
        let searchList = try! JSONDecoder().decode(SearchList.self, from: json) as SearchList
        
        artist = searchList.artists.items.first
    }
    
    func testListAlbums_Success() {
        let waitForRequest = expectation(description: "testListAlbums_Success")
        let service = MockArtistAlbumsService(testOption: .success(list))
        let controller = ArtistAlbumsController(service: service)
        let delegate = MockArtistAlbumsDelegate()
        
        controller.delegate = delegate
        controller.fetchAlbums(byArtists: artist)
        XCTAssertTrue(delegate.didCallAlbumsload)
        XCTAssertFalse(delegate.didCallFailLoad)
        DispatchQueue.main.async {
            waitForRequest.fulfill()
            XCTAssertEqual(controller.albums.count, 2)
            XCTAssertEqual(controller.page, 1)
            XCTAssert(controller.showNotFoundAlbums == false)
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    
    func testListAlbums_NextPage() {
        let waitForRequest = expectation(description: "testListAlbums_NextPage")
        let service = MockArtistAlbumsService(testOption: .success(list))
        let controller = ArtistAlbumsController(service: service)
        let delegate = MockArtistAlbumsDelegate()
        
        XCTAssertEqual(controller.initialPage, controller.page)
        controller.delegate = delegate
        controller.fetchAlbums(byArtists: artist)
        XCTAssertTrue(delegate.didCallAlbumsload)
        XCTAssertEqual(controller.initialPage + 1, controller.page)
        controller.fetchNextPage()
        controller.fetchNextPage()
        DispatchQueue.main.async { [weak controller] in
            XCTAssertEqual(controller?.page, 3)
            XCTAssertFalse(controller?.retrevingResults ?? true)
            XCTAssertFalse(controller?.showNotFoundAlbums ?? true)
            waitForRequest.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testListAlbums_Failure() {
        let waitForRequest = expectation(description: "testListAlbums_Failure")
        let service = MockArtistAlbumsService(testOption: .noInternetConnection)
        let controller = ArtistAlbumsController(service: service)
        let delegate = MockArtistAlbumsDelegate()
        
        controller.delegate = delegate
        controller.fetchAlbums(byArtists: artist)
        XCTAssertFalse(delegate.didCallAlbumsload)
        XCTAssertTrue(delegate.didCallFailLoad)
        DispatchQueue.main.async { [weak controller] in
            XCTAssertTrue(controller?.showNotFoundAlbums ?? false)
            XCTAssertEqual(controller?.errorMessage, ServiceError.noInternetConnection.localizedDescription)
            waitForRequest.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
}
