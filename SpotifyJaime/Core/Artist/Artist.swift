//
//  Artist.swift
//  SpotifyJaime
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import Foundation

struct Artist : Codable {
    let followers: Int
    let images: [RawImage]
    let name: String
    let popularity: Int
    let id: String

    enum FollowersKeys: String, CodingKey {
        case total
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: Artist.CodingKeys.self)
        let followersValues = try values.nestedContainer(keyedBy: FollowersKeys.self, forKey: .followers)
    
        followers = try followersValues.decode(Int.self, forKey: .total)
        id = try values.decode(String.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        images = try values.decode([RawImage].self, forKey: .images)
        popularity = try values.decode(Int.self, forKey: .popularity)
    }
}

struct RawImage : Codable {
    let url : String
    let height : Int
    let width : Int
}
