//
//  ServiceFactoryTest.swift
//  SpotifyJaimeTests
//
//  Created by Jaime Andres Laino Guerra on 7/31/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import XCTest
@testable import SpotifyJaime

class ServiceFactoryTest: XCTestCase { }

//SearchService
extension ServiceFactoryTest {
    func testSearchService() {
        let webService = ServiceFactory.searchService()
        
        XCTAssertNotNil((webService as? SearchWebService))
    }
    
    func testSearchService_MockSuccess() {
        CommandLine.arguments.removeAll()
        CommandLine.arguments.append("--MockSearchService-Success")
        
        let service = ServiceFactory.searchService() as? MockSearchService
        
        guard case MockSearchService.TestOptions.success(_)? = service?.testOption else {
            XCTFail()
            return
        }
    }
    
    func testSearchService_MockFailure() {
        CommandLine.arguments.removeAll()
        CommandLine.arguments.append("--MockSearchService-Failure")
        
        let service = ServiceFactory.searchService() as? MockSearchService
        
        guard case MockSearchService.TestOptions.failure(_)? = service?.testOption else {
            XCTFail()
            return
        }
    }
    
    func testSearchService_MockNoInternet() {
        CommandLine.arguments.removeAll()
        CommandLine.arguments.append("--MockSearchService-NoInternet")
        
        let service = ServiceFactory.searchService() as? MockSearchService
        
        guard case MockSearchService.TestOptions.noInternetConnection? = service?.testOption else {
            XCTFail()
            return
        }
    }
}

//ArtistService
extension ServiceFactoryTest {
    func testArtistService() {
        let webService = ServiceFactory.artistService()
        
        XCTAssertNotNil((webService as? ArtistWebService))
    }
    
    func testArtistService_MockSuccess() {
        CommandLine.arguments.removeAll()
        CommandLine.arguments.append("--MockArtistService-Success")
        
        let service = ServiceFactory.artistService() as? MockArtistService
        
        guard case MockArtistService.TestOptions.success(_)? = service?.testOption else {
            XCTFail()
            return
        }
    }
    
    func testArtistService_MockFailure() {
        CommandLine.arguments.removeAll()
        CommandLine.arguments.append("--MockArtistService-Failure")
        
        let service = ServiceFactory.artistService() as? MockArtistService
        
        guard case MockArtistService.TestOptions.failure(_)? = service?.testOption else {
            XCTFail()
            return
        }
    }
    
    func testArtistService_MockNoInternet() {
        CommandLine.arguments.removeAll()
        CommandLine.arguments.append("--MockArtistService-NoInternet")
        
        let service = ServiceFactory.artistService() as? MockArtistService
        
        guard case MockArtistService.TestOptions.noInternetConnection? = service?.testOption else {
            XCTFail()
            return
        }
    }
}

//ArtistAlbumsService
extension ServiceFactoryTest {
    func testArtistAlbumsService() {
        let webService = ServiceFactory.artistAlbumsService()
        
        XCTAssertNotNil((webService as? ArtistAlbumsService))
    }
    
    func testArtistAlbumsService_MockSuccess() {
        CommandLine.arguments.removeAll()
        CommandLine.arguments.append("--MockArtistAlbumsService-Success")
        
        let service = ServiceFactory.artistAlbumsService() as? MockArtistAlbumsService
        
        guard case MockArtistAlbumsService.TestOptions.success(_)? = service?.testOption else {
            XCTFail()
            return
        }
    }
    
    func testArtistAlbumsService_MockFailure() {
        CommandLine.arguments.removeAll()
        CommandLine.arguments.append("--MockArtistAlbumsService-Failure")
        
        let service = ServiceFactory.artistAlbumsService() as? MockArtistAlbumsService
        
        guard case MockArtistAlbumsService.TestOptions.failure(_)? = service?.testOption else {
            XCTFail()
            return
        }
    }
    
    func testArtistAlbumsService_MockNoInternet() {
        CommandLine.arguments.removeAll()
        CommandLine.arguments.append("--MockArtistAlbumsService-NoInternet")
        
        let service = ServiceFactory.artistAlbumsService() as? MockArtistAlbumsService
        
        guard case MockArtistAlbumsService.TestOptions.noInternetConnection? = service?.testOption else {
            XCTFail()
            return
        }
    }
}
