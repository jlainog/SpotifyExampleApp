//
//  SearchService.swift
//  SpotifyJaime
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import Foundation

struct SearchList: Codable {
    var query : String?
    let artists : ArtistList
    let albums : AlbumsList?
}

protocol SearchService {
    func search(_ query: String, handler: @escaping (Result<SearchList>) -> Void)
}
