//
//  ArtistService.swift
//  SpotifyJaime
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import Foundation

struct ArtistList : Codable {
    let items: [Artist]
    let total: Int
}

protocol ArtistService {
    func search(_ query: String, page: Int, handler: @escaping (Result<ArtistList>) -> Void)
}
