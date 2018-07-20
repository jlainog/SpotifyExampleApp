//
//  AlbumViewModel.swift
//  SpotifyJaime
//
//  Created by Jaime Andres Laino Guerra on 7/20/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import Foundation

struct AlbumViewModel {
    let name: String
    let availableMarkets: String
    
    init(album: Album) {
        self.name = album.name
        
        guard let availableMarkets = album.availableMarkets, availableMarkets.count > 0 else {
            self.availableMarkets = ""
            return
        }
        
        if availableMarkets.count > 5 {
            self.availableMarkets = "Available in: \(album.availableMarkets!.count)"
        } else {
            let countries = "Available in: " + availableMarkets.joined(separator: ", ")

            self.availableMarkets = countries
        }
    }
}
