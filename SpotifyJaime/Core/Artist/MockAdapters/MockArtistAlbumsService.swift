//
//  MockArtistAlbumsService.swift
//  SpotifyJaime
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import Foundation

struct MockArtistAlbumsService : ArtistAlbumsService {
    enum TestOptions {
        case success(AlbumsList)
        case failure(String)
        case noInternetConnection
    }
    let testOption : TestOptions
    
    init(testOption: TestOptions) {
        self.testOption = testOption
    }
    
    func getAlbums(_ artist: Artist, page: Int, handler: @escaping (Result<AlbumsList>) -> Void) {
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
