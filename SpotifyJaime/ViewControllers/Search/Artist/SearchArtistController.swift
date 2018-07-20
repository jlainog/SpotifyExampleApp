//
//  SearchArtistController.swift
//  SpotifyJaime
//
//  Created by Jaime Andres Laino Guerra on 7/16/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import UIKit

protocol SearchArtistControllerDelegate : class {
    func didLoadArtists()
    func didFail()
}

class SearchArtistController {
    private let searchService: ArtistService
    private var count : Int = 0
    
    let initialPage = 0
    private(set) var query = ""
    private(set) var page : Int
    private(set) var retrevingResults = false
    private(set) var artists: [Artist] = []
    private(set) var artistImages : [ImageViewModel] = []
    private(set) var errorMessage: String?
    private(set) var showNoFoundArtists : Bool = false
    weak var delegate : SearchArtistControllerDelegate?
    
    required init(service: ArtistService) {
        self.searchService = service
        self.page = initialPage
    }
    
    func search(byQuery query: String) {
        page = initialPage
        self.query = query
        fetchNextPage()
    }
    
    func fetchNextPage() {
        if query.isEmpty { return }
        if retrevingResults { return }
        if page != initialPage && count != 0 && count <= artists.count { return }
        
        retrevingResults = true
        searchService.search(query, page: page) { (result) in
            result
                .error { self.handleError($0 as! ServiceError) }
                .value { self.handleList($0) }
        }
    }
    
    private func handleError(_ error: ServiceError) {
        updateRetrevingResuts()
        showNoFoundArtists = artists.count == 0
        self.errorMessage = error.localizedDescription
        delegate?.didFail()
    }
    
    private func handleList(_ list: ArtistList) {
        let artistImages = list.items.map { (item) -> ImageViewModel in
            let image = item.images.sorted { (lhs, rhs) -> Bool in
                return lhs.width < rhs.width
                }.last
            return ImageViewModel(imageURL: image?.url)
        }
        
        updateRetrevingResuts()
        artists.append(contentsOf: list.items)
        self.artistImages.append(contentsOf: artistImages)
        showNoFoundArtists = artists.count == 0
        page += 1
        count = list.total
        delegate?.didLoadArtists()
    }
    
    private func updateRetrevingResuts() {
        retrevingResults = false
        
        if page == initialPage {
            count = 0
            artists = []
            artistImages = []
        }
    }
}
