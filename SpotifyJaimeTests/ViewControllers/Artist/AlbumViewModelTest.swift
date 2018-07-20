//
//  AlbumViewModelTest.swift
//  SpotifyJaimeTests
//
//  Created by Jaime Andres Laino Guerra on 7/20/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import XCTest
@testable import SpotifyJaime

class AlbumViewModelTest: XCTestCase {
    
    var list : AlbumsList!
    
    override func setUp() {
        super.setUp()
        let path = Bundle.main.path(forResource: "ArtistsAlbumsResponse", ofType: "json")
        let json = try! Data.init(contentsOf: URL(fileURLWithPath: path!))
        let list = try! JSONDecoder().decode(AlbumsList.self, from: json) as AlbumsList
        
        self.list = list
    }
    
    func testAlbumViewModel() {
        for album in list.items {
            let viewModel = AlbumViewModel(album: album)
            
            XCTAssertEqual(viewModel.name, album.name)
            XCTAssert(viewModel.availableMarkets.hasPrefix("Available in:"))
            
            if let count = album.availableMarkets?.count, count > 5 {
                XCTAssert(viewModel.availableMarkets.hasSuffix("\(count)"))
            } else {
                XCTAssert(viewModel.availableMarkets.hasSuffix((album.availableMarkets?.last)!))
            }
        }
    }

}
