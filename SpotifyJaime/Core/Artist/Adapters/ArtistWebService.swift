//
//  ArtistWebService.swift
//  SpotifyJaime
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import Foundation
import Alamofire

struct ArtistWebService {
    private let pageLimit = 15
    let concurrentRequest = ConcurrentValue<DataRequest>(queueLabel: "ArtistAlbumService")
}

extension ArtistWebService : ArtistService {
    func search(_ query: String, page: Int, handler: @escaping (Result<ArtistList>) -> Void) {
        SpotifyAccessTokenHandler.shared.request { result in
            result.error { handler(.Failure($0)) }
                .value { (token) in
                    let urlRequest = SpotifyAPI.baseURL + SpotifyAPI.seachPath
                    
                    DispatchQueue.global().async {
                        let dataRequest = Alamofire.request(urlRequest,
                                                        parameters: ["q": query,
                                                                     "offset": (page * self.pageLimit),
                                                                     "type": "artist",
                                                                     "limit": self.pageLimit],
                                                        headers: ["Authorization":token.OAuthToken()])
                        
                        
                        self.concurrentRequest.value?.cancel()
                        self.concurrentRequest.value = dataRequest
                        dataRequest.responseJSON { (response) in
                            if (self.concurrentRequest.value!.request != dataRequest.request) { return }
                            
                            let result = SpotifyAPI.handleResponse(response)
                                .flatMap { SpotifyAPI.parse($0) as Result<SearchList> }
                                .map { $0.artists }
                            
                            DispatchQueue.main.async {
                                handler(result)
                            }
                        }
                    }
            }
        }
    }
}

extension ArtistWebService: ArtistAlbumsService {
    func getAlbums(_ artist: Artist, page: Int, handler: @escaping (Result<AlbumsList>) -> Void) {
        SpotifyAccessTokenHandler.shared.request { result in
            result.error { handler(.Failure($0)) }
                .value { (token) in
                    let albumsPath = String(format: SpotifyAPI.albumsPath, arguments: [artist.id])
                    let urlRequest = SpotifyAPI.baseURL + albumsPath
                    
                    Alamofire.request(urlRequest,
                                      parameters: ["offset": (page * self.pageLimit),
                                                   "limit": self.pageLimit],
                                      headers: ["Authorization": token.OAuthToken()])
                        .responseJSON { (response) in
                            let result = SpotifyAPI.handleResponse(response)
                                .flatMap { SpotifyAPI.parse($0) } as Result<AlbumsList>
                            
                            handler(result)
                    }
            }
        }
    }
}
