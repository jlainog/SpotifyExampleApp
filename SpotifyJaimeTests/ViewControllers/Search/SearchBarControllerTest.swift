//
//  SearchBarControllerTest.swift
//  SpotifyJaimeTests
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import XCTest
@testable import SpotifyJaime

class SearchBarControllerTest: XCTestCase {
    
    let vc = UIViewController()
    var sut : SearchBarController!
    
    override func setUp() {
        super.setUp()
        
        sut = SearchBarController(vc, placeHolder: "placeHolder")
    }
    
    func testSearchBarController_didClickSearchButton() {
        let waitForRequest = expectation(description: "testSearchBarController_didClickSearchButton")
        
        sut.onDidClickSearchButton = { query in
            XCTAssertEqual(query, "MyQuery".lowercased())
            waitForRequest.fulfill()
        }
        
        sut.searchBar.text = "MyQuery"
        sut.searchBarSearchButtonClicked(sut.searchBar)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testSearchBarController_onTextDidChange() {
        let waitForRequest = expectation(description: "testSearchBarController_didClickSearchButton")

        sut.onTextDidChange = { query in
            XCTAssertEqual(query, "MyQuery".lowercased())
            waitForRequest.fulfill()
        }
        
        sut.searchBar.text = "MyQuery"
        sut.searchBar(sut.searchBar, textDidChange: sut.searchBar.text!)
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testSearchBarController_onTextDidClear() {
        let waitForRequest = expectation(description: "testSearchBarController_didClickSearchButton")
        
        sut.onTextDidClear = {
            XCTAssertEqual(self.sut.searchController.searchBar.placeholder, "placeHolder")
            waitForRequest.fulfill()
        }
        
        sut.searchBar.text = "MyQuery"
        sut.searchBar(sut.searchBar, textDidChange: "")
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testSearchBarController_removeSpecialCharacters() {
        sut.searchBar.text = "MyQuery\"\\“\\’\\‘\\`\\”\\“\\„»«\'"
        sut.searchBar(sut.searchBar, textDidChange: sut.searchBar.text!)
        XCTAssertEqual(sut.searchBar.text, "MyQuery".lowercased())
    }
    
    func testSearchBarController_shouldBeginEditing() {
        _ = sut.searchBarShouldBeginEditing(sut.searchBar)
        XCTAssertTrue(vc.definesPresentationContext)
    }
    
    func testSearchBarController_searchButtonClicked() {
        sut.searchBarSearchButtonClicked(sut.searchBar)
        XCTAssertFalse(sut.searchController.isActive)
    }
    
}
