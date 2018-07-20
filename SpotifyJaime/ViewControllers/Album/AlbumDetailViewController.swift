//
//  AlbumDetailViewController.swift
//  SpotifyJaime
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import UIKit

final class AlbumDetailViewController: UIViewController {
    private var artist: Artist?
    private var album: Album!
    private var artistImageViewModel : ImageViewModel!
    private var albumImageViewModel : ImageViewModel!
    private var backgroundImageViewModel : ImageViewModel!

    @IBOutlet weak var artistImageView: UIImageView!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!

    func set(artist: Artist?, album: Album) {
        self.artist = artist
        self.album = album
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let artist = self.artist {
            artistImageViewModel = ImageViewModel(imageURL: getRawImage(artist.images)?.url)
            artistImageViewModel.loadImageIn(imageView: artistImageView)
            artistNameLabel.text = artist.name
        }
        
        albumNameLabel.text = album.name
        albumImageViewModel = ImageViewModel(imageURL: getRawImage(album.images)?.url)
        albumImageViewModel.loadImageIn(imageView: albumImageView, roundImage: false)
        albumImageViewModel.loadImageIn(imageView: backgroundImageView, roundImage: false)
    }
    
    @IBAction func onOpenInSpotify(_ sender: Any) {
        UIApplication.shared.open(album.externalURL, completionHandler: nil)
    }
    
    private func getRawImage(_ images: [RawImage]) -> RawImage? {
        return images.sorted { (lhs, rhs) -> Bool in
            return lhs.width < rhs.width
            }.last
    }
}
