//
//  ArtistCollectionViewCell.swift
//  SpotifyJaime
//
//  Created by Jaime Andres Laino Guerra on 7/16/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import UIKit
import AlamofireImage

class ArtistCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var followers: UILabel!
    @IBOutlet weak var popularity: UILabel!
    
    func configure(_ artist: Artist) {
        name.text = artist.name
        followers.text = "Followers: " + String(artist.followers)
        popularity.text = "Popularity: " + String(artist.popularity)
    }
    
    override func prepareForReuse() {
        name.text = ""
        followers.text = ""
        popularity.text = ""
        imageView.image = nil
    }
}
