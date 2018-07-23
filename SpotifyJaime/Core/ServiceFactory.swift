//
//  ServiceFactory.swift
//  SpotifyJaime
//
//  Created by Jaime Andres Laino Guerra on 7/22/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import Foundation

struct ServiceFactory {
    static func searchService() -> SearchService {
        if CommandLine.arguments.contains("--MockSearchService-Success") {
            let path = Bundle.main.path(forResource: "SearchResponse", ofType: "json")
            let json = try! Data.init(contentsOf: URL(fileURLWithPath: path!))
            let searchList = try! JSONDecoder().decode(SearchList.self, from: json) as SearchList
            
            return MockSearchService(testOption: .success(searchList))
        } else if CommandLine.arguments.contains("--MockSearchService-Failure") {
            return MockSearchService(testOption: .failure("Mock Failure"))
        } else if CommandLine.arguments.contains("--MockSearchService-NoInternet") {
            return MockSearchService(testOption: .noInternetConnection)
        }
        
        return SearchWebService()
    }
    
    static func artistService() -> ArtistService {
        if CommandLine.arguments.contains("--MockArtistService-Success") {
            let path = Bundle.main.path(forResource: "SearchResponse", ofType: "json")
            let json = try! Data.init(contentsOf: URL(fileURLWithPath: path!))
            let searchList = try! JSONDecoder().decode(SearchList.self, from: json) as SearchList
            
            return MockArtistService(testOption: .success(searchList.artists))
        } else if CommandLine.arguments.contains("--MockArtistService-Failure") {
            return MockArtistService(testOption: .failure("Mock Failure"))
        } else if CommandLine.arguments.contains("--MockArtistService-NoInternet") {
            return MockArtistService(testOption: .noInternetConnection)
        }
        
        return ArtistWebService()
    }
    
    static func artistAlbumsService() -> ArtistAlbumsService {
        if CommandLine.arguments.contains("--MockArtistAlbumsService-Success") {
            let path = Bundle.main.path(forResource: "ArtistsAlbumsResponse", ofType: "json")
            let json = try! Data.init(contentsOf: URL(fileURLWithPath: path!))
            let list = try! JSONDecoder().decode(AlbumsList.self, from: json) as AlbumsList
            
            return MockArtistAlbumsService(testOption: .success(list))
        } else if CommandLine.arguments.contains("--MockArtistAlbumsService-Failure") {
            return MockArtistAlbumsService(testOption: .failure("Mock Failure"))
        } else if CommandLine.arguments.contains("--MockArtistAlbumsService-NoInternet") {
            return MockArtistAlbumsService(testOption: .noInternetConnection)
        }
        
        return ArtistWebService()
    }
}
