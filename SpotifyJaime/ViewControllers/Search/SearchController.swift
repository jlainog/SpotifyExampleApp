//
//  SearchController.swift
//  SpotifyJaime
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import Foundation

protocol SearchControllerDelegate : class {
    func didLoadResults()
    func didFail()
}

enum SearchSections {
    case topArtist(Artist, ImageViewModel)
    case albums([Album], [ImageViewModel])
    case artist([Artist], [ImageViewModel])
    
    func count() -> Int {
        switch self {
        case .topArtist(_, _): return 1
        case .artist(let artists, _): return artists.count
        case .albums(let artists, _): return artists.count
        }
    }
}

class SearchController {
    private let searchService: SearchService
    
    private(set) var query = ""
    private(set) var retrevingResults = false
    private(set) var sections = [SearchSections]()
    private(set) var errorMessage: String?
    private(set) var showNotFoundResults : Bool = false
    weak var delegate : SearchControllerDelegate?
    
    required init(service: SearchService) {
        self.searchService = service
    }
    
    func search(byQuery query: String) {
        self.query = query
        searchService.search(query) { (result) in
            result
                .error { self.handleError($0 as! ServiceError) }
                .value { self.handleList($0) }
        }
    }
    
    private func handleError(_ error: ServiceError) {
        showNotFoundResults = (sections.count == 0)
        self.errorMessage = error.localizedDescription
        delegate?.didFail()
    }
    
    private func handleList(_ list: SearchList) {
        let artistImages = list.artists.items.map { (item) -> ImageViewModel in
            let image = item.images.sorted { (lhs, rhs) -> Bool in
                return lhs.width < rhs.width
                }.last
            return ImageViewModel(imageURL: image?.url)
        }
        let albumsImages = list.albums?.items.map { (item) -> ImageViewModel in
            let image = item.images.sorted { (lhs, rhs) -> Bool in
                return lhs.width < rhs.width
                }.last
            return ImageViewModel(imageURL: image?.url)
        }
        
        sections.removeAll()
        
        if let topArtist = list.artists.items.first {
            sections.append(SearchSections.topArtist(topArtist, artistImages.first!))
        }
        
        if let albums = list.albums,
            albums.items.count != 0 {
            let albums = SearchSections.albums(albums.items, albumsImages!)
            sections.append(albums)
        }
        
        if list.artists.items.count != 0 {
            let artist = SearchSections.artist(list.artists.items, artistImages)
            sections.append(artist)
        }

        showNotFoundResults = (sections.count == 0)
        delegate?.didLoadResults()
    }
}
