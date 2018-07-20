//
//  ArtistAlbumsController.swift
//  SpotifyJaime
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import Foundation

protocol ArtistAlbumsControllerDelegate : class {
    func didLoadAlbums()
    func didFail()
}

class ArtistAlbumsController {
    private let service: ArtistAlbumsService
    private var count : Int = 0
    
    let initialPage = 0
    private(set) var artist : Artist!
    private(set) var page : Int
    private(set) var retrevingResults = false
    private(set) var albums: [Album] = []
    private(set) var albumsImages : [ImageViewModel] = []
    private(set) var errorMessage: String?
    private(set) var showNotFoundAlbums : Bool = false
    weak var delegate : ArtistAlbumsControllerDelegate?
    
    required init(service: ArtistAlbumsService) {
        self.service = service
        self.page = initialPage
    }
    
    func fetchAlbums(byArtists artist: Artist) {
        page = initialPage
        self.artist = artist
        fetchNextPage()
    }
    
    func fetchNextPage() {
        guard let selectedArtists = artist else { return }
        if retrevingResults { return }
        if page != initialPage && count != 0 && count <= albums.count { return }
        
        retrevingResults = true
        service.getAlbums(selectedArtists, page: page) { (result) in
            result
                .error { self.handleError($0 as! ServiceError) }
                .value { self.handleList($0) }
        }
    }
    
    private func handleError(_ error: ServiceError) {
        updateRetrevingResuts()
        showNotFoundAlbums = albums.count == 0
        self.errorMessage = error.localizedDescription
        delegate?.didFail()
    }
    
    private func handleList(_ list: AlbumsList) {
        let albumsImages = list.items.map { (item) -> ImageViewModel in
            let image = item.images.sorted { (lhs, rhs) -> Bool in
                return lhs.width < rhs.width
                }.last
            return ImageViewModel(imageURL: image?.url)
        }
        
        updateRetrevingResuts()
        albums.append(contentsOf: list.items)
        self.albumsImages.append(contentsOf: albumsImages)
        showNotFoundAlbums = albums.count == 0
        page += 1
        count = list.total
        delegate?.didLoadAlbums()
    }
    
    private func updateRetrevingResuts() {
        retrevingResults = false
        
        if page == initialPage {
            count = 0
            albums = []
            albumsImages = []
        }
    }
}
