//
//  ArtistAlbumsService.swift
//  SpotifyJaime
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import Foundation

struct AlbumsList: Codable {
    let items: [Album]
    let total: Int
}

protocol ArtistAlbumsService {
    func getAlbums(_ artist: Artist, page: Int, handler: @escaping (Result<AlbumsList>) -> Void)
}
