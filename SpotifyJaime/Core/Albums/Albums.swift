//
//  Albums.swift
//  SpotifyJaime
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import Foundation

struct Album : Codable {
    let id: String
    let availableMarkets : [String]?
    let externalURL : URL
    let images: [RawImage]
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case availableMarkets = "available_markets"
        case externalURL = "external_urls"
        case name
        case images
    }
    
    enum ExternalURLKeys: String, CodingKey {
        case spotify
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: Album.CodingKeys.self)
        let externalURLValues = try values.nestedContainer(keyedBy: ExternalURLKeys.self, forKey: .externalURL)
        let urlString = try externalURLValues.decode(String.self, forKey: .spotify)
        
        id = try values.decode(String.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        images = try values.decode([RawImage].self, forKey: .images)
        availableMarkets = try values.decodeIfPresent([String].self, forKey: .availableMarkets)
        externalURL = URL(string: urlString) ?? URL(string: "https://open.spotify.com")!
    }
}
