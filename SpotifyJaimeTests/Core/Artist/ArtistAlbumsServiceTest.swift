//
//  ArtistAlbumsServiceTest.swift
//  SpotifyJaimeTests
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import XCTest
@testable import SpotifyJaime

class ArtistAlbumsServiceTest: XCTestCase {
    
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
    
    func testArtistAlbumsService_Success() {
        let waitForRequest = expectation(description: "testArtistAlbumsService_Success")
        let service = MockArtistAlbumsService(testOption: .success(list))
        
        service.getAlbums(artist, page: 0) { (result) in
            let list = try! result.resolve()
            
            waitForRequest.fulfill()
            XCTAssert(list.items.count == 2)
            XCTAssert(list.total == 527)
        }
        wait(for: [waitForRequest], timeout: 0.2)
    }
    
    func testArtistAlbumsService_Failure() {
        let waitForRequest = expectation(description: "testArtistAlbumsService_Failure")
        let mockError = "MockError"
        let service = MockArtistAlbumsService(testOption: .failure(mockError))
        
         service.getAlbums(artist, page: 0) { (result) in
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
    
    func testArtistAlbumsService_NoInternet() {
        let waitForRequest = expectation(description: "testArtistAlbumsService_NoInternet")
        let service = MockArtistAlbumsService(testOption: .noInternetConnection)
        
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
        wait(for: [waitForRequest], timeout: 0.2)
    }
    
}
