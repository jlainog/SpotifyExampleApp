//
//  MockArtistService.swift
//  SpotifyJaime
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import Foundation

struct MockArtistService : ArtistService {
    enum TestOptions {
        case success(ArtistList)
        case failure(String)
        case noInternetConnection
    }
    let testOption : TestOptions
    
    init(testOption: TestOptions) {
        self.testOption = testOption
    }
    
    func search(_ query: String, page: Int, handler: @escaping (Result<ArtistList>) -> Void) {
        handler(Result {
            switch testOption {
            case .success(let list):
                return list
            case .failure(let error):
                throw ServiceError.failure(error)
            case .noInternetConnection:
                throw ServiceError.noInternetConnection
            }
        })
    }
}
