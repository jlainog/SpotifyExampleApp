//
//  SpotifyJaimeUITests.swift
//  SpotifyJaimeUITests
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import XCTest

class SpotifyJaimeUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    func testNew() {
        let app = launchApp(["--MockSearchService-Success", "--MockArtistService-Success", "--MockArtistAlbumsService-Success"])
        search("Muse", app: app)
        
        let collectionViewsQuery2 = app.collectionViews
        let cellsQuery = collectionViewsQuery2.cells
        cellsQuery.otherElements.containing(.staticText, identifier:"artist.title").element.tap()
        
        let albumTitleElement = collectionViewsQuery2.children(matching: .cell).element(boundBy: 0).otherElements.containing(.staticText, identifier:"album.title").element
        albumTitleElement.tap()
        app.staticTexts["album.title"].tap()
        app.otherElements.containing(.navigationBar, identifier:"SpotifyJaime.AlbumDetailView").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).tap()
        app.staticTexts["artist.title.detail"].tap()
        
        let backButton = app.navigationBars["SpotifyJaime.AlbumDetailView"].buttons["Back"]
        backButton.tap()
        
        let backButton2 = app.navigationBars["SpotifyJaime.ArtistsAlbumsView"].buttons["Back"]
        backButton2.tap()
        
        let collectionView = app.otherElements.containing(.navigationBar, identifier:"SpotifyJaime.SearchView").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .collectionView).element
        collectionView.swipeUp()
        
        let collectionViewsQuery = collectionViewsQuery2
        
        collectionViewsQuery2.children(matching: .cell).element(boundBy: 1).otherElements.containing(.staticText, identifier:"album.title").element.tap()
        backButton.tap()
        collectionView.swipeUp()
        collectionViewsQuery/*@START_MENU_TOKEN@*/.staticTexts["Followers: 3935484"]/*[[".cells.staticTexts[\"Followers: 3935484\"]",".staticTexts[\"Followers: 3935484\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()    
    }
    
    func testSearch_Failure() {
        let app = launchApp(["--MockSearchService-Failure"])
        
        search("Muse", app: app)
        let exists = app.alerts.staticTexts["Mock Failure"].exists
        XCTAssertTrue(exists)
    }
    
    func testSearch_NoInternet() {
        let app = launchApp(["--MockSearchService-NoInternet"])
        
        search("Muse", app: app)
        let exists = app.alerts.staticTexts["No Internet Connection"].exists
        XCTAssertTrue(exists)
    }
    
    func testArtists_Failure() {
        let app = launchApp(["--MockSearchService-Success", "--MockArtistService-Failure"])
        
        search("Muse", app: app)

        let collectionViewsQuery = app.collectionViews
        let artistsButton = collectionViewsQuery.buttons["Artists >"]
        
        app.otherElements.containing(.navigationBar, identifier:"SpotifyJaime.SearchView").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .collectionView).element.swipeUp()
        artistsButton.tap()

        let exists = app.alerts.staticTexts["Mock Failure"].exists
        XCTAssertTrue(exists)
    }
    
    func testArtists_NoInternet() {
        let app = launchApp(["--MockSearchService-Success", "--MockArtistService-NoInternet"])
        
        search("Muse", app: app)
        
        let collectionViewsQuery = app.collectionViews
        let artistsButton = collectionViewsQuery.buttons["Artists >"]
        
        app.otherElements.containing(.navigationBar, identifier:"SpotifyJaime.SearchView").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .collectionView).element.swipeUp()
        artistsButton.tap()
        
        let exists = app.alerts.staticTexts["No Internet Connection"].exists
        XCTAssertTrue(exists)
    }
    
    func testArtistsAlbums_Failure() {
        let app = launchApp(["--MockSearchService-Success", "--MockArtistAlbumsService-Failure"])
        
        search("Muse", app: app)

        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.cells.otherElements.containing(.staticText, identifier:"artist.title").element.tap()

        let exists = app.alerts.staticTexts["Mock Failure"].exists
        XCTAssertTrue(exists)
    }
    
    func testArtistsAlbums_NoInternet() {
        let app = launchApp(["--MockSearchService-Success", "--MockArtistAlbumsService-NoInternet"])
        
        search("Muse", app: app)
        
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.cells.otherElements.containing(.staticText, identifier:"artist.title").element.tap()
        
        let exists = app.alerts.staticTexts["No Internet Connection"].exists
        XCTAssertTrue(exists)
    }
    
    func launchApp(_ argumments: [String]? = nil) -> XCUIApplication {
        let app = XCUIApplication()
        
        app.launchArguments = argumments ?? [String]()
        app.launch()
        return app
    }
    
    func search(_ query: String, app: XCUIApplication) {
        app.navigationBars["SpotifyJaime.SearchView"].searchFields["Search Artist"].tap()
        let textfield = app.navigationBars["SpotifyJaime.SearchView"].searchFields["Search Artist"]
        
        textfield.typeText(query)
        app/*@START_MENU_TOKEN@*/.keyboards.buttons["Search"]/*[[".keyboards.buttons[\"Search\"]",".buttons[\"Search\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/.tap()
    }
}
